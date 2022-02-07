import HandyOperators

// these coordinates take a base coord and reduce it into (less) equivalence classes through symmetries

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
struct ReducedFlipUDSliceCoordinate: ReducedCoordinate, CoordinateWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let moveTable = FaceTurnMoveTable<Self>()
	
	static let (representants, classIndices) = computeRepresentants()
	
	var index: UInt16
	var symmetry: StandardSymmetry
}

protocol ReducedCoordinate: CoordinateWithMoveTable {
	associatedtype BaseCoord: CoordinateWithSymmetries where CubeState == BaseCoord.CubeState
	associatedtype ClassIndex: FixedWidthInteger
	
	typealias Representant = ReducedRepresentant<BaseCoord>
	
	static var count: Int { get }
	static var representants: [Representant] { get }
	static var classIndices: [ClassIndex] { get }
	
	static func computeRepresentants() -> ([Representant], [UInt16])
	
	var index: ClassIndex { get }
	var symmetry: StandardSymmetry { get set }
	
	var representant: Representant { get }
	
	init(index: ClassIndex, symmetry: StandardSymmetry)
	init(index: Int, symmetryIndex: Int)
	init(_ baseCoord: BaseCoord)
}

extension ReducedCoordinate {
	static var count: Int { representants.count }
	
	var representant: Representant {
		Self.representants[intValue]
	}
	
	init(index: Int, symmetryIndex: Int) {
		self.init(index: .init(index), symmetry: .init(index: symmetryIndex))
	}
	
	init<I>(_ value: I) where I: BinaryInteger {
		self.init(index: .init(value), symmetry: StandardSymmetry.zero)
	}
	
	var intValue: Int {
		Int(index)
	}
	
	init(_ baseCoord: BaseCoord) {
		let (symmetry, representant) = StandardSymmetry.all
			.lazy
			.map { ($0, coord: baseCoord.shifted(with: $0)) }
			.min { $0.coord < $1.coord }!
		let index = Self.classIndices[representant.intValue]
		self.init(index: .init(index), symmetry: symmetry)
	}
	
	var description: String {
		"\(Self.self)(\(index), S\(symmetry.index))"
	}
	
	init(_ state: BaseCoord.CubeState) {
		self.init(BaseCoord(state))
	}
	
	func makeState() -> CubeState {
		representant.coord
			.shifted(with: symmetry.inverse)
			.makeState()
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		(lhs.index, lhs.symmetry.storedIndex) < (rhs.index, rhs.symmetry.storedIndex)
	}
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		moveTable[coord][coord.symmetry.shift(move)] <- {
			// TODO: make sure this is correct by comparing to unreduced versions
			$0.symmetry = coord.symmetry + $0.symmetry
		}
	}
	
	static func computeRepresentants() -> ([Representant], [ClassIndex]) {
		measureTime(as: "computeRepresentants for \(Self.self)") {
			var representants: [Representant] = []
			representants.reserveCapacity(BaseCoord.count / Symmetry.standardSubgroup.count)
			var classIndices: [ClassIndex] = .init(repeating: .max, count: BaseCoord.count)
			for coord in BaseCoord.allValues {
				guard classIndices[coord.intValue] == .max else { continue }
				
				let classIndex = ClassIndex(representants.endIndex)
				let new = Representant(coord: coord) <- { representant in
					for symmetry in StandardSymmetry.all {
						let shifted = coord.shifted(with: symmetry)
						if shifted == coord {
							representant.addSymmetry(symmetry)
						}
						if classIndices[shifted.intValue] == .max {
							classIndices[shifted.intValue] = classIndex
						}
					}
				}
				representants.append(new)
			}
			
			return (representants, classIndices)
		}
	}
}

struct ReducedRepresentant<BaseCoord: Coordinate> {
	var coord: BaseCoord
	var symmetriesMask: UInt16 = 1
	
	var hasSymmetries: Bool {
		symmetriesMask != 1
	}
	
	func hasSymmetry(_ symmetry: StandardSymmetry) -> Bool {
		symmetriesMask & (1 << symmetry.storedIndex) != 0
	}
	
	fileprivate mutating func addSymmetry(_ symmetry: StandardSymmetry) {
		symmetriesMask |= 1 << symmetry.storedIndex
	}
}
