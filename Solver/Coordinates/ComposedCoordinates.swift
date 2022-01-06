import HandyOperators

// these coordinates compose two underlying coords into one

/// Combines the UD slice coordinate with the edge orientation (flip).
struct FlipUDSliceCoordinate: ComposedCoordinate, CoordinateWithSymmetryTable {
	static let standardSymmetryTable = computeSymmetryTable()
	
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
	
	private static func computeSymmetryTable() -> StandardSymmetryTable<Self> {
		/**
		 - **we can compute the symmetry table much faster with some clever math to avoid computing stuff multiple times**
		 
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
			let flipParts = zip(udSlicePart[coord.udSlice], flipPart[coord.flip])
			return StandardSymmetryEntry(
				moves: zip(coord.udSlice.standardSymmetries, flipParts)
					.map { Self($0, $1.0 + $1.1) } // could use pointfree notation but this outperforms that by ~10%
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

struct Phase1Coordinate: ComposedCoordinate, CoordinateWithMoves {
	var corners: CornerOrientationCoordinate
	var reduced: ReducedFlipUDSliceCoordinate
	
	var outerCoord: ReducedFlipUDSliceCoordinate { reduced }
	var innerCoord: CornerOrientationCoordinate { corners }
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		//let newReduced = reduced + move
		//let oldSym = ReducedFlipUDSliceCoordinate.Space.symmetryToRepresentant[]
		return .init(coord.reduced + move, coord.corners + move)
	}
}

extension Phase1Coordinate {
	init(_ reduced: ReducedFlipUDSliceCoordinate, _ corners: CornerOrientationCoordinate) {
		self.reduced = reduced
		self.corners = corners
	}
	
	init(_ state: CubeTransformation) {
		self.init(.init(state.edges), .init(state.corners.orientation))
	}
	
	func makeState() -> CubeTransformation {
		return .init(
			corners: .init(orientation: corners.makeState()),
			edges: reduced.makeState()
		)
	}
}
