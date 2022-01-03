protocol Coordinate: Hashable, Comparable {
	associatedtype CubeState: PartialCubeState
	associatedtype Value: BinaryInteger where Value.Stride: SignedInteger
	
	static var count: Value { get }
	static var validSymmetries: [Symmetry] { get }
	
	init(_ state: CubeState)
	func makeState() -> CubeState
	
	var value: Value { get }
	var intValue: Int { get }
	init(value: Value)
	init<I: BinaryInteger>(_ value: I)
}

extension Coordinate {
	static var validSymmetries: [Symmetry] { Symmetry.standardSubgroup }
	
	static var allValues: LazyMapSequence<Range<Value>, Self> {
		(0..<count).lazy.map(Self.init)
	}
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		assert(value < Self.count)
		self.init(value: .init(value))
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.value < rhs.value
	}
}

protocol CoordinateWithSymmetryTable: Coordinate {
	static var standardSymmetryTable: StandardSymmetryTable<Self> { get }
}

extension CoordinateWithSymmetryTable {
	var standardSymmetries: [Self] {
		Self.standardSymmetryTable[self].moves
	}
}

protocol CoordinateWithMoves: Coordinate {
	static func + (coord: Self, move: SolverMove) -> Self
}

protocol CoordinateWithMoveTable: CoordinateWithMoves {
	static var moveTable: FaceTurnMoveTable<Self> { get }
}

extension CoordinateWithMoveTable {
	static func + (coord: Self, move: SolverMove) -> Self {
		moveTable[coord][move]
	}
}
