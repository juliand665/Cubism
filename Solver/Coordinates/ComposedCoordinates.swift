import HandyOperators

// these coordinates compose two underlying coords into one

/// Combines the UD slice coordinate with the edge orientation (flip).
struct FlipUDSliceCoordinate: CoordinateWithSymmetryTable {
	static let count = UInt32(UDSliceCoordinate.count) * UInt32(EdgeOrientationCoordinate.count)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
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
