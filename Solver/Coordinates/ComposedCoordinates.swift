import HandyOperators

// these coordinates compose two underlying coords into one

// TODO: maybe just store the separate coordinates (perhaps not even numerically) and multiply only when needed? for phase 1 i'm pretty sure this takes no more space. should shadow allValues though

/// Combines the UD slice coordinate with the edge orientation (flip).
struct FlipUDSliceCoordinate: CoordinateWithSymmetryTable {
	static let count = UInt32(UDSliceCoordinate.count) * UInt32(EdgeOrientationCoordinate.count)
	
	static let standardSymmetryTable = computeSymmetryTable()
	
	var value: UInt32
}

extension FlipUDSliceCoordinate {
	var components: (udSlice: UDSliceCoordinate, orientation: EdgeOrientationCoordinate) {
		let (udSlice, orientation) = value.quotientAndRemainder(dividingBy: .init(EdgeOrientationCoordinate.count))
		return (.init(udSlice), .init(orientation))
	}
	
	init(_ permutation: EdgePermutation, _ orientation: EdgeOrientation) {
		self.init(permutation.udSliceCoordinate(), orientation.coordinate())
	}
	
	init(_ udSlice: UDSliceCoordinate, _ orientation: EdgeOrientationCoordinate) {
		value = .init(udSlice.value) * .init(EdgeOrientationCoordinate.count) + .init(orientation.value)
	}
	
	init(_ state: CubeTransformation.Edges) {
		self.init(state.permutation, state.orientation)
	}
	
	func makeState() -> CubeTransformation.Edges {
		let (udSlice, orientation) = components
		return .init(
			permutation: udSlice.makeState(),
			orientation: orientation.makeState()
		)
	}
	
	private static func computeSymmetryTable() -> StandardSymmetryTable<Self> {
		/**
		 # we can compute the symmetry table much faster with some clever math to avoid computing stuff multiple times
		 
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
		
		let udSlicePart = MoveTable(for: UDSliceCoordinate.self) { permutation in
			Symmetry.standardSubgroup.map {
				($0.forward.edges.orientation.applying(permutation) + $0.backward).coordinate()
			}
		}
		let flipPart = MoveTable(for: EdgeOrientationCoordinate.self) { orientation in
			Symmetry.standardSubgroup.map {
				orientation.applying($0.backward.edges.permutation).coordinate()
			}
		}
		
		// TODO: at this point is it even meaningful to make a move table for this or should we just provide functionality based on the other two?
		// note that the move table lets us reference arrays of the symmetries for ease of use
		// i profiled it and it looks like it's all just allocations and such, so that would probably be a whole lot better
		return .init { coord in
			let (udSlice, flip) = coord.components
			let flipParts = zip(udSlicePart[udSlice], flipPart[flip])
			return StandardSymmetryEntry(
				moves: zip(udSlice.standardSymmetries, flipParts)
					.map { Self($0, $1.0 + $1.1) } // could use pointfree notation but this outperforms that by ~20%
			)
		}/* <- { fast in
			let slow = StandardSymmetryTable<Self>()
			for (fastEntry, slowEntry) in zip(fast.entries, slow.entries) {
				precondition(fastEntry.moves == slowEntry.moves)
			}
		}*/
	}
}

extension EdgeOrientationCoordinate {
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(value: lhs.value ^ rhs.value)
	}
}

struct Phase1Coordinate: CoordinateWithMoves {
	static let count = UInt32(CornerOrientationCoordinate.count) * UInt32(ReducedFlipUDSliceCoordinate.count)
	
	var value: UInt32
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		let (reduced, corners) = coord.components
		//let newReduced = reduced + move
		//let oldSym = ReducedFlipUDSliceCoordinate.Space.symmetryToRepresentant[]
		return .init(reduced + move, corners + move)
	}
}

extension Phase1Coordinate {
	var components: (reduced: ReducedFlipUDSliceCoordinate, corners: CornerOrientationCoordinate) {
		let (reduced, corners) = value.quotientAndRemainder(dividingBy: .init(CornerOrientationCoordinate.count))
		return (.init(reduced), .init(corners))
	}
	
	init(_ reduced: ReducedFlipUDSliceCoordinate, _ corners: CornerOrientationCoordinate) {
		value = .init(reduced.value) * .init(CornerOrientationCoordinate.count) + .init(corners.value)
	}
	
	init(_ state: CubeTransformation) {
		self.init(.init(state.edges), .init(state.corners.orientation))
	}
	
	func makeState() -> CubeTransformation {
		let (reduced, corners) = components
		
		return .init(
			corners: .init(orientation: corners.makeState()),
			edges: reduced.makeState()
		)
	}
}
