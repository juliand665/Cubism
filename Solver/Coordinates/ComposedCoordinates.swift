import HandyOperators

// these coordinates compose two underlying coords into one

/// Combines the UD slice coordinate with the edge orientation (flip).
struct FlipUDSliceCoordinate: ComposedCoordinate, CoordinateWithSymmetries {
	var flip: EdgeOrientationCoordinate
	var udSlice: UDSliceCoordinate
	
	var outerCoord: UDSliceCoordinate { udSlice }
	var innerCoord: EdgeOrientationCoordinate { flip }
}

extension FlipUDSliceCoordinate {
	init(_ permutation: EdgePermutation, _ orientation: EdgeOrientation) {
		self.init(permutation.udSliceCoordinate(), orientation.coordinate())
	}
	
	init(_ udSlice: UDSliceCoordinate, _ flip: EdgeOrientationCoordinate) {
		self.udSlice = udSlice
		self.flip = flip
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
			udSlice.shifted(with: symmetry),
			Self.udSlicePart[udSlice][symmetry] + Self.flipPart[flip][symmetry]
		)
	}
}

extension EdgeOrientationCoordinate {
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(value: lhs.value ^ rhs.value)
	}
}

struct Phase1Coordinate: PruningCoordinate {
	static let pruningTable = PruningTable<Self>.cached().load()
	static let allowedMoves = SolverMove.all
	
	var reduced: ReducedFlipUDSliceCoordinate
	var corners: CornerOrientationCoordinate
	
	var outerCoord: ReducedFlipUDSliceCoordinate { reduced }
	var innerCoord: CornerOrientationCoordinate { corners }
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		let reduced = coord.reduced + move
		let oldSymmetry = coord.reduced.symmetry
		let newSymmetry = reduced.symmetry
		
		// this mirrors the computation of `coord.reduced + move`
		let shiftedMove = oldSymmetry.shift(move)
		let corners = (coord.corners + shiftedMove).shifted(with: newSymmetry * oldSymmetry.inverse)
		
		// alternative equivalent version with 3 rather than 2 lookups in big tables (likely cache misses):
		//let unshifted = coord.corners.shifted(with: oldSymmetry.inverse)
		//let corners = (unshifted + move).shifted(with: newSymmetry)
		
		return .init(reduced, corners)
	}
}

extension Phase1Coordinate {
	init(_ reduced: ReducedFlipUDSliceCoordinate, _ corners: CornerOrientationCoordinate) {
		self.reduced = reduced
		self.corners = corners
	}
	
	init(_ state: CubeTransformation) {
		let reduced = ReducedFlipUDSliceCoordinate(state.edges)
		self.init(
			reduced: reduced,
			corners: .init(state.corners.orientation).shifted(with: reduced.symmetry)
		)
	}
	
	func makeState() -> CubeTransformation {
		.init(
			corners: .init(orientation: corners.shifted(with: reduced.symmetry).makeState()),
			edges: reduced.makeState()
		)
	}
}

struct Phase2Coordinate: PruningCoordinate {
	static let pruningTable = PruningTable<Self>.cached().load()
	static let allowedMoves = SolverMove.phase1Preserving
	
	var reduced: ReducedCornerPermutationCoordinate
	var edges: NonSliceEdgePermutationCoordinate
	
	var outerCoord: ReducedCornerPermutationCoordinate { reduced }
	var innerCoord: NonSliceEdgePermutationCoordinate { edges }
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		let shiftedMove = coord.reduced.symmetry.shift(move)
		let reduced = coord.reduced + move
		let corners = (coord.edges + shiftedMove).shifted(with: reduced.symmetry)
		return .init(reduced, corners)
	}
}

extension Phase2Coordinate {
	init(_ reduced: ReducedCornerPermutationCoordinate, _ edges: NonSliceEdgePermutationCoordinate) {
		self.reduced = reduced
		self.edges = edges
	}
	
	init(_ state: CubeTransformation) {
		let reduced = ReducedCornerPermutationCoordinate(state.corners.permutation)
		self.init(
			reduced: reduced,
			edges: .init(state.edges.permutation).shifted(with: reduced.symmetry)
		)
	}
	
	func makeState() -> CubeTransformation {
		.init(
			cornerPermutation: reduced.makeState(),
			edgePermutation: edges.shifted(with: reduced.symmetry).makeState()
		)
	}
}
