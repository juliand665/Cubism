// these coordinates aren't direct representations of any partial cube state, but still just simple numbers (not composed or reduced)

/// Describes where the 4 edges belonging in the UD slice are currently, ignoring order.
struct UDSliceCoordinate: CoordinateWithSymmetryTable {
	typealias CubeState = EdgePermutation
	
	static let count: UInt16 = 495 // nCr(12, 8)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt16
}

extension UDSliceCoordinate {
	init(_ state: EdgePermutation) {
		self = state.udSliceCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		.init(self)
	}
}

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
