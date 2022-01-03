// these coordinates directly represent a partial cube state

protocol PartialCubeStateWithCoord: PartialCubeState {
	associatedtype Coord: Coordinate
	
	init(_ coordinate: Coord)
	func coordinate() -> Coord
}

struct CornerOrientationCoordinate: CoordinateWithMoveTable, CoordinateWithSymmetryTable {
	typealias CubeState = CornerOrientation
	
	static let count: UInt16 = 2187 // 3^7
	
	static let moveTable = FaceTurnMoveTable<Self>()
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt16
}

struct EdgeOrientationCoordinate: CoordinateWithSymmetryTable {
	typealias CubeState = EdgeOrientation
	
	static let count: UInt16 = 2048 // 2^11
	static let validSymmetries = Symmetry.edgeFlipPreservingSubgroup
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt16
}

struct CornerPermutationCoordinate: Coordinate {
	typealias CubeState = CornerPermutation
	
	static let count: UInt16 = 40_320 // 8!
	
	var value: UInt16
}

struct EdgePermutationCoordinate: Coordinate {
	typealias CubeState = EdgePermutation
	
	static let count: UInt32 = 479_001_600 // 12!
	
	var value: UInt32
}

extension Coordinate where CubeState: PartialCubeStateWithCoord, CubeState.Coord == Self {
	init(_ state: CubeState) {
		self = state.coordinate()
	}
	
	func makeState() -> CubeState {
		.init(self)
	}
}
