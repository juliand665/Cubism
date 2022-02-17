// these coordinates directly represent a partial cube state

protocol PartialCubeStateWithCoord { // conformance to PartialCubeState implied by the associatedtype—swift is weird sometimes…
	associatedtype Coord: SimpleCoordinate where Coord.CubeState == Self
	
	init(_ coordinate: Coord)
	func coordinate() -> Coord
}

struct CornerOrientationCoordinate: SimpleCoordinate, CoordinateWithMoveTable, CoordinateWithSymmetryTable {
	typealias CubeState = CornerOrientation
	
	static let count = 2187 // 3^7
	
	static let moveTable = FaceTurnMoveTable<Self>.cached().load()
	static let standardSymmetryTable = StandardSymmetryTable<Self>.cached().load()
	
	var value: UInt16
}

struct EdgeOrientationCoordinate: SimpleCoordinate, CoordinateWithSymmetryTable {
	typealias CubeState = EdgeOrientation
	
	static let count = 2048 // 2^11
	static let validSymmetries = Symmetry.edgeFlipPreservingSubgroup
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>.cached().load()
	
	var value: UInt16
}

struct CornerPermutationCoordinate: SimpleCoordinate, CoordinateWithSymmetryTable {
	typealias CubeState = CornerPermutation
	
	static let count = 40_320 // 8!
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>.cached().load()
	
	var value: UInt16
}

struct EdgePermutationCoordinate: SimpleCoordinate {
	typealias CubeState = EdgePermutation
	
	static let count = 479_001_600 // 12!
	
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
