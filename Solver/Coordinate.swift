import Foundation

struct Coordinate<Space: CoordinateSpace>: Hashable {
	typealias Space = Space // make generic arg accessible as member
	
	static var allValues: LazyMapSequence<Range<Int>, Coordinate<Space>> {
		(0..<Space.count).lazy.map(Self.init)
	}
	
	var value: UInt
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		self.value = .init(value)
		assert(value < Space.count)
	}
	
	init(_ state: Space.CubeState) {
		self = Space.makeCoordinate(from: state)
	}
	
	func makeState() -> Space.CubeState {
		Space.makeState(from: self)
	}
}

protocol CoordinateSpace {
	associatedtype CubeState: PartialCubeState
	typealias Coord = Coordinate<Self>
	
	static var count: Int { get }
	static var validSymmetries: [CubeTransformation] { get }
	
	static func makeState(from coordinate: Coord) -> CubeState
	static func makeCoordinate(from state: CubeState) -> Coord
}

extension CoordinateSpace {
	static var validSymmetries: [CubeTransformation] { Symmetry.standardSubgroup }
}

typealias CornerOrientationCoordinate = Coordinate<_CornerOrientationCoordinateSpace>
struct _CornerOrientationCoordinateSpace: CoordinateSpace {
	static let count = 2187 // 3^7
	
	static func makeState(from coordinate: Coord) -> CornerOrientations {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: CornerOrientations) -> Coord {
		state.coordinate()
	}
}

typealias EdgeOrientationCoordinate = Coordinate<_EdgeOrientationCoordinateSpace>
struct _EdgeOrientationCoordinateSpace: CoordinateSpace {
	static let count = 2048 // 2^11
	
	static let validSymmetries = Symmetry.edgeFlipPreservingSubgroup
	
	static func makeState(from coordinate: Coord) -> EdgeOrientations {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgeOrientations) -> Coord {
		state.coordinate()
	}
}

typealias CornerPermutationCoordinate = Coordinate<_CornerPermutationCoordinateSpace>
struct _CornerPermutationCoordinateSpace: CoordinateSpace {
	static let count = 40_320 // 8!
	
	static func makeState(from coordinate: Coord) -> CornerPermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: CornerPermutation) -> Coord {
		state.coordinate()
	}
}

typealias EdgePermutationCoordinate = Coordinate<_EdgePermutationCoordinateSpace>
struct _EdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 479_001_600 // 12!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.coordinate()
	}
}

/// Describes where the 4 edges belonging in the UD slice are currently, ignoring order.
typealias UDSliceCoordinate = Coordinate<_UDSliceCoordinateSpace>
struct _UDSliceCoordinateSpace: CoordinateSpace {
	static let count = 495 // nCr(12, 8)
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.udSliceCoordinate()
	}
}

/// Combines the UD slice coordinate with the edge orientation (flip).
typealias FlipUDSliceCoordinate = Coordinate<_FlipUDSliceCoordinateSpace>
struct _FlipUDSliceCoordinateSpace: CoordinateSpace {
	static let count = UDSliceCoordinate.Space.count * EdgeOrientationCoordinate.Space.count
	
	static func makeState(from coordinate: Coord) -> CubeTransformation {
		let (udSlice, orientation) = coordinate.value.quotientAndRemainder(dividingBy: UInt(EdgeOrientationCoordinate.Space.count))
		return .init(
			edgePermutation: .init(UDSliceCoordinate(udSlice)),
			edgeOrientations: .init(EdgeOrientationCoordinate(orientation))
		)
	}
	
	static func makeCoordinate(from state: CubeTransformation) -> Coord {
		.init(state.edgePermutation, state.edgeOrientations)
	}
}

extension FlipUDSliceCoordinate {
	var udSliceCoord: UDSliceCoordinate {
		.init(value / UInt(EdgeOrientationCoordinate.Space.count))
	}
	
	var edgeOrientationCoord: EdgeOrientationCoordinate {
		.init(value % UInt(EdgeOrientationCoordinate.Space.count))
	}
	
	init(_ permutation: EdgePermutation, _ orientations: EdgeOrientations) {
		self.init(permutation.udSliceCoordinate(), orientations.coordinate())
	}
	
	init(_ udSlice: UDSliceCoordinate, _ orientation: EdgeOrientationCoordinate) {
		value = udSlice.value * UInt(EdgeOrientationCoordinate.Space.count) + orientation.value
	}
}

/// For phase 2. Describes how the 4 UD slice edges are permuted, assuming they're within their slice.
typealias SliceEdgePermutationCoordinate = Coordinate<_SliceEdgePermutationCoordinateSpace>
struct _SliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 24 // 4!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		fatalError("TODO")
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.sliceEdgePermCoordinate()
	}
}

/// For phase 2. Describes how the 8 non-UD slice edges are permuted, assuming they're outside the slice.
typealias NonSliceEdgePermutationCoordinate = Coordinate<_NonSliceEdgePermutationCoordinateSpace>
struct _NonSliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count = 40_320 // 8!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		fatalError("TODO")
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.nonSliceEdgePermCoordinate()
	}
}
