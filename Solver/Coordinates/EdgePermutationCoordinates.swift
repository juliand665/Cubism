/// For phase 2. Describes how the 4 UD slice edges are permuted, assuming they're within their slice.
struct SliceEdgePermutationCoordinate: Coordinate {
	static let count: UInt8 = 24 // 4!
	
	var value: UInt8
}

extension SliceEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		self = state.sliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		fatalError("TODO")
	}
}

/// For phase 2. Describes how the 8 non-UD slice edges are permuted, assuming they're outside the slice.
struct NonSliceEdgePermutationCoordinate: Coordinate {
	static let count: UInt16 = 40_320 // 8!
	
	var value: UInt16
}

extension NonSliceEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		self = state.nonSliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		fatalError("TODO")
	}
}

extension EdgePermutation {
	func sliceEdgePermCoordinate() -> SliceEdgePermutationCoordinate {
		asArray()
			.filter { $0.isPartOfUDSlice }
			.permutationCoordinate()
	}
	
	func nonSliceEdgePermCoordinate() -> NonSliceEdgePermutationCoordinate {
		asArray()
			.filter { !$0.isPartOfUDSlice }
			.permutationCoordinate()
	}
}