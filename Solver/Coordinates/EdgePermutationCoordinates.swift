/// For phase 2. Describes how the 4 UD slice edges are permuted, assuming they're within their slice.
struct SliceEdgePermutationCoordinate: SimpleCoordinate, CoordinateWithMoveTable, CoordinateWithSymmetryTable {
	static let count = 24 // 4!
	
	static let moveTable = FaceTurnMoveTable<Self>()
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt8
}

extension SliceEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		self = state.sliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		.init(
			array: []
			+ Edge.allCases.prefix(8)
			+ Edge.allCases.suffix(4).reorderedToMatch(self)
		)
	}
}

/// For phase 2. Describes how the 8 non-UD slice edges are permuted, assuming they're outside the slice.
struct NonSliceEdgePermutationCoordinate: SimpleCoordinate, CoordinateWithMoveTable, CoordinateWithSymmetryTable {
	static let count = 40_320 // 8!
	
	static let moveTable = FaceTurnMoveTable<Self>()
	static let standardSymmetryTable = StandardSymmetryTable<Self>.cached().load()
	
	var value: UInt16
}

extension NonSliceEdgePermutationCoordinate {
	private static let order: [Edge] = [.ur, .uf, .ul, .ub, .dr, .df, .dl, .db]
	
	init(_ state: EdgePermutation) {
		self = state.nonSliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		.init(
			array: []
			+ Edge.allCases.prefix(8).reorderedToMatch(self)
			+ Edge.allCases.suffix(4)
		)
	}
}

extension EdgePermutation {
	func sliceEdgePermCoordinate() -> SliceEdgePermutationCoordinate {
		filter { $0.isPartOfUDSlice }.permutationCoordinate()
	}
	
	func nonSliceEdgePermCoordinate() -> NonSliceEdgePermutationCoordinate {
		filter { !$0.isPartOfUDSlice }.permutationCoordinate()
	}
}
