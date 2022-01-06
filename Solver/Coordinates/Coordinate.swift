protocol Coordinate: Hashable, Comparable {
	associatedtype CubeState: PartialCubeState
	associatedtype AllValues: Collection where AllValues.Element == Self // collection so map knows how many to allocate
	
	static var count: Int { get }
	static var allValues: AllValues { get }
	
	static var validSymmetries: [Symmetry] { get }
	
	init(_ state: CubeState)
	func makeState() -> CubeState
	
	var intValue: Int { get }
	init<I: BinaryInteger>(_ value: I)
	
	static var zero: Self { get }
	var isZero: Bool { get }
}

extension Coordinate {
	static var validSymmetries: [Symmetry] { Symmetry.standardSubgroup }
	
	static var allValues: LazyMapSequence<Range<Int>, Self> {
		(0..<count).lazy.map(Self.init)
	}
}

protocol SimpleCoordinate: Coordinate {
	associatedtype Value: BinaryInteger where Value.Stride: SignedInteger
	
	var value: Value { get }
	init(value: Value)
}

extension SimpleCoordinate {
	static var countAsValue: Value { Value(count) }
	static var allValues: LazyMapSequence<Range<Value>, Self> {
		(0..<countAsValue).lazy.map(Self.init)
	}
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		assert(value < Self.count)
		self.init(value: .init(value))
	}
	
	static var zero: Self { .init(value: 0) }
	var isZero: Bool { value == 0 }
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.value < rhs.value
	}
}

protocol ComposedCoordinate {
	associatedtype OuterCoord: SimpleCoordinate
	associatedtype InnerCoord: SimpleCoordinate
	
	var outerCoord: OuterCoord { get }
	var innerCoord: InnerCoord { get }
	
	init(_ outerCoord: OuterCoord, _ innerCoord: InnerCoord)
}

extension ComposedCoordinate {
	static var count: Int { OuterCoord.count * InnerCoord.count }
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.outerCoord < rhs.outerCoord
		|| lhs.outerCoord == rhs.outerCoord && lhs.innerCoord < rhs.innerCoord
	}
	
	var intValue: Int {
		outerCoord.intValue * InnerCoord.count + innerCoord.intValue
	}
	
	init<I: BinaryInteger>(_ value: I) {
		let (outer, inner) = value.quotientAndRemainder(dividingBy: .init(InnerCoord.count))
		self.init(.init(outer), .init(inner))
	}
	
	static var zero: Self { .init(.zero, .zero) }
	var isZero: Bool {
		outerCoord.isZero && innerCoord.isZero
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
