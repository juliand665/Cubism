protocol Coordinate: Hashable, Comparable, CustomStringConvertible {
	associatedtype CubeState: PartialCubeState
	associatedtype AllValues: Collection where AllValues.Element == Self // collection so map knows how many to allocate
	
	static var count: Int { get }
	static var allValues: AllValues { get }
	
	static var validSymmetries: [Symmetry] { get }
	
	var isZero: Bool { get }
	
	init(_ state: CubeState)
	func makeState() -> CubeState
	
	var intValue: Int { get }
	init<I: BinaryInteger>(_ value: I)
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
	
	var isZero: Bool { value == 0 }
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		assert(value < Self.count)
		self.init(value: .init(value))
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.value < rhs.value
	}
	
	var description: String {
		"\(Self.self)(\(value))"
	}
}

protocol ComposedCoordinate {
	associatedtype OuterCoord: Coordinate
	associatedtype InnerCoord: Coordinate
	
	var outerCoord: OuterCoord { get }
	var innerCoord: InnerCoord { get }
	
	init(outer: OuterCoord, inner: InnerCoord)
}

extension ComposedCoordinate {
	static var count: Int { OuterCoord.count * InnerCoord.count }
	
	var isZero: Bool { outerCoord.isZero && innerCoord.isZero }
	
	var intValue: Int {
		outerCoord.intValue * InnerCoord.count + innerCoord.intValue
	}
	
	init<I: BinaryInteger>(_ value: I) {
		let (outer, inner) = value.quotientAndRemainder(dividingBy: .init(InnerCoord.count))
		self.init(outer: .init(outer), inner: .init(inner))
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.outerCoord < rhs.outerCoord
		|| lhs.outerCoord == rhs.outerCoord && lhs.innerCoord < rhs.innerCoord
	}
	
	var description: String {
		"\(Self.self)(outer: \(outerCoord), inner: \(innerCoord))"
	}
}

protocol CoordinateWithSymmetries: Coordinate {
	func shifted(with symmetry: StandardSymmetry) -> Self
}

protocol CoordinateWithSymmetryTable: CoordinateWithSymmetries {
	static var standardSymmetryTable: StandardSymmetryTable<Self> { get }
}

extension CoordinateWithSymmetryTable {
	func shifted(with symmetry: StandardSymmetry) -> Self {
		Self.standardSymmetryTable[self].moves[symmetry.index]
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
