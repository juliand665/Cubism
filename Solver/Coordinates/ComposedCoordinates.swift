import HandyOperators

// these coordinates compose two underlying coords into one

/// Combines the UD slice coordinate with the edge orientation (flip).
struct FlipUDSliceCoordinate: ComposedCoordinate, CoordinateWithSymmetries {
	var udSlice: UDSliceCoordinate
	var flip: EdgeOrientationCoordinate
	
	var outerCoord: UDSliceCoordinate { udSlice }
	var innerCoord: EdgeOrientationCoordinate { flip }
}

extension FlipUDSliceCoordinate {
	init(_ permutation: EdgePermutation, _ orientation: EdgeOrientation) {
		self.init(udSlice: permutation.udSliceCoordinate(), flip: orientation.coordinate())
	}
	
	init(outer: UDSliceCoordinate, inner: EdgeOrientationCoordinate) {
		self.init(udSlice: outer, flip: inner)
	}
	
	init(_ state: CubeTransformation.Edges) {
		self.init(state.permutation, state.orientation)
	}
	
	func makeState() -> CubeTransformation.Edges {
		return .init(
			permutation: udSlice.makeState(),
			orientation: flip.makeState()
		)
	}
}

/**
 - **we can compute the symmetries much faster with some clever math to avoid computing stuff multiple times**
 
 we want to calculate `(symmetry.forward + flipUDSlice + symmetry.backward).edges.orientation`
 (for readability, we'll shorten `edges.orientation` to `eo` and `edges.permutation` to `ep`, as well as taking some formal liberties)
 
 that is `forward.eo.applying(udSlice) + flip + backward`
 which is `(forward.eo.applying(udSlice) + flip).applying(backward.ep) + backward.eo`
 note that applying permutations is distributive over composing orientations: `(a + b).applying(p) = a.applying(p) + b.applying(b)`
 hence `(a + b).applying(p) + c = a.applying(p) + c + b.applying(b)`
 which we can apply here: `forward.eo.applying(udSlice).applying(backward.ep) + flip.applying(backward.ep) + backward.eo`
 reorder: `forward.eo.applying(udSlice).applying(backward.ep) + backward.eo + flip.applying(backward.ep)`
 simplify: `forward.eo.applying(udSlice) + backward.edges + flip.applying(backward.ep)`
 
 note that the first term only depends on the UDSlice part, the second term is constant, and the third term only depends on the Flip part
 we can precompute both, then simply compose them with an XOR on the coordinate
 */
extension FlipUDSliceCoordinate {
	typealias Symmetries = StandardSymmetryEntry<EdgeOrientationCoordinate>
	
	private static let udSlicePart = MoveTable<UDSliceCoordinate, Symmetries>.cached {
		MoveTable(for: UDSliceCoordinate.self) { permutation in
			StandardSymmetryEntry {
				($0.forward.edges.orientation.applying(permutation) + $0.backward).coordinate()
			}
		}
	}.name("\(Self.self).udSlicePart").load()
	
	private static let flipPart = MoveTable<EdgeOrientationCoordinate, Symmetries>.cached {
		MoveTable(for: EdgeOrientationCoordinate.self) { orientation in
			StandardSymmetryEntry {
				orientation.applying($0.backward.edges.permutation).coordinate()
			}
		}
	}.name("\(Self.self).flipPart").load()
	
	func shifted(with symmetry: StandardSymmetry) -> Self {
		.init(
			udSlice: udSlice.shifted(with: symmetry),
			flip: Self.udSlicePart[udSlice][symmetry] + Self.flipPart[flip][symmetry]
		)
	}
}

extension EdgeOrientationCoordinate {
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(value: lhs.value ^ rhs.value)
	}
}

struct Phase1Coordinate: PruningCoordinate, SolverCoordinate {
	// TODO: why do i need this??
	typealias OuterCoord = ReducedFlipUDSliceCoordinate
	typealias InnerCoord = CornerOrientationCoordinate
	
	static let pruningTable = PruningTable<Self>.cached().load()
	static let allowedMoves = SolverMove.all
	
	var reduced: ReducedFlipUDSliceCoordinate
	var corners: CornerOrientationCoordinate
	
	var symmetryCoord: ReducedFlipUDSliceCoordinate {
		get { reduced }
		set { reduced = newValue }
	}
	var basicCoord: CornerOrientationCoordinate { corners }
}

extension Phase1Coordinate {
	init(symmetry: ReducedFlipUDSliceCoordinate, basic: CornerOrientationCoordinate) {
		self.init(reduced: symmetry, corners: basic)
	}
	
	init(_ state: CubeTransformation) {
		let reduced = ReducedFlipUDSliceCoordinate(state.edges)
		self.init(
			reduced: reduced,
			corners: .init(state.corners.orientation)
		)
	}
	
	init(full: Self) { self = full }
	
	func makeState() -> CubeTransformation {
		.init(
			corners: .init(orientation: corners.makeState()),
			edges: reduced.makeState()
		)
	}
}

struct Phase2Coordinate: PruningCoordinate {
	typealias OuterCoord = ReducedCornerPermutationCoordinate
	typealias InnerCoord = NonSliceEdgePermutationCoordinate
	
	static let pruningTable = PruningTable<Self>.cached().load()
	static let allowedMoves = SolverMove.phase1Preserving
	
	var reduced: ReducedCornerPermutationCoordinate
	var edges: NonSliceEdgePermutationCoordinate
	
	var symmetryCoord: ReducedCornerPermutationCoordinate {
		get { reduced }
		set { reduced = newValue }
	}
	var basicCoord: NonSliceEdgePermutationCoordinate { edges }
}

extension Phase2Coordinate {
	init(symmetry: ReducedCornerPermutationCoordinate, basic: NonSliceEdgePermutationCoordinate) {
		self.init(reduced: symmetry, edges: basic)
	}
	
	init(_ state: CubeTransformation) {
		self.init(
			reduced: .init(state.corners.permutation),
			edges: .init(state.edges.permutation)
		)
	}
	
	init(full: FullPhase2Coordinate) {
		self = full.base
	}
	
	func makeState() -> CubeTransformation {
		.init(
			cornerPermutation: reduced.makeState(),
			edgePermutation: edges.makeState()
		)
	}
}

struct FullPhase2Coordinate: HalfSymmetryCoordinate {
	typealias OuterCoord = Phase2Coordinate
	typealias InnerCoord = SliceEdgePermutationCoordinate
	
	typealias CubeState = CubeTransformation
	
	var base: Phase2Coordinate
	var slice: SliceEdgePermutationCoordinate
	
	var symmetryCoord: Phase2Coordinate {
		get { base }
		set { base = newValue }
	}
	var basicCoord: SliceEdgePermutationCoordinate { slice }
}

extension FullPhase2Coordinate: SolverCoordinate {
	static var allowedMoves: [SolverMove] {
		Phase2Coordinate.allowedMoves
	}
	
	var minDistance: UInt8 {
		base.pruningValue
	}
}

extension FullPhase2Coordinate {
	init(symmetry: Phase2Coordinate, basic: SliceEdgePermutationCoordinate) {
		self.init(base: symmetry, slice: basic)
	}
	
	init(_ state: CubeTransformation) {
		let base = Phase2Coordinate(state)
		self.init(
			base: base,
			slice: .init(state.edges.permutation)
		)
	}
	
	func makeState() -> CubeTransformation {
		base.makeState() <- {
			$0.edges.permutation += slice.makeState()
		}
	}
}

protocol HalfSymmetryCoordinate: ComposedCoordinate, SymmetryCoordinate
where OuterCoord: SymmetryCoordinate, InnerCoord: CoordinateWithSymmetries {
	var symmetryCoord: OuterCoord { get set }
	var basicCoord: InnerCoord { get }
	
	init(symmetry: OuterCoord, basic: InnerCoord)
}

extension HalfSymmetryCoordinate {
	var symmetry: StandardSymmetry {
		get { symmetryCoord.symmetry }
		set { symmetryCoord.symmetry = newValue }
	}
	
	var outerCoord: OuterCoord { symmetryCoord }
	
	/// reframed to match the symmetry of the outer coord
	var innerCoord: InnerCoord {
		basicCoord.shifted(with: symmetry)
	}
	
	init(outer: OuterCoord, inner: InnerCoord) {
		self.init(
			symmetry: outer,
			basic: inner.shifted(with: outer.symmetry.inverse)
		)
	}
	
	var description: String {
		"\(Self.self)(symmetry: \(symmetryCoord), basic: \(basicCoord))"
	}
}

extension CoordinateWithMoves
where Self: HalfSymmetryCoordinate, OuterCoord: CoordinateWithMoves, InnerCoord: CoordinateWithMoves {
	static func + (coord: Self, _ move: SolverMove) -> Self {
		.init(
			symmetry: coord.symmetryCoord + move,
			basic: coord.basicCoord + move
		)
	}
}
