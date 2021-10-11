import Foundation

struct Coordinate<Space: CoordinateSpace>: Hashable {
	typealias Space = Space // make generic arg accessible as member
	
	var value: UInt
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		self.value = .init(value)
		assert(value < Space.count)
	}
}

protocol CoordinateSpace {
	static var count: Int { get }
}

typealias CornerOrientationCoordinate = Coordinate<_CornerOrientationCoordinateSpace>
struct _CornerOrientationCoordinateSpace: CoordinateSpace {
	static let count = 2187 // 3^7
}

typealias EdgeOrientationCoordinate = Coordinate<_EdgeOrientationCoordinateSpace>
struct _EdgeOrientationCoordinateSpace: CoordinateSpace {
	static let count = 2048 // 2^11
}

typealias CornerPermutationCoordinate = Coordinate<_CornerPermutationCoordinateSpace>
struct _CornerPermutationCoordinateSpace: CoordinateSpace {
	static let count = 40_320 // 8!
}

typealias EdgePermutationCoordinate = Coordinate<_EdgePermutationCoordinateSpace>
struct _EdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 479_001_600 // 12!
}

typealias UDSliceCoordinate = Coordinate<_UDSliceCoordinateSpace>
struct _UDSliceCoordinateSpace: CoordinateSpace {
	static let count = 495 // nCr(12, 8)
}

typealias FlipUDSliceCoordinate = Coordinate<_FlipUDSliceCoordinateSpace>
struct _FlipUDSliceCoordinateSpace: CoordinateSpace {
	static let count = UDSliceCoordinate.Space.count * EdgeOrientationCoordinate.Space.count
}

typealias SliceEdgePermutationCoordinate = Coordinate<_SliceEdgePermutationCoordinateSpace>
struct _SliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 24 // 4!
}

typealias NonSliceEdgePermutationCoordinate = Coordinate<_NonSliceEdgePermutationCoordinateSpace>
struct _NonSliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 40_320 // 8!
}
