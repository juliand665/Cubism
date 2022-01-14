import HandyOperators

// these coordinates take a base coord and reduce it into (less) equivalence classes through symmetries

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
struct ReducedFlipUDSliceCoordinate: Coordinate, CoordinateWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let count = representants.count
	static let moveTable = FaceTurnMoveTable<Self>()
	
	static let (representants, classIndices) = computeRepresentants()
	
	var index: UInt16
	var symmetry: StandardSymmetry
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		(lhs.index, lhs.symmetry.storedIndex) < (rhs.index, rhs.symmetry.storedIndex)
	}
	
	static func + (coord: Self, _ move: SolverMove) -> Self {
		moveTable[coord][coord.symmetry.shift(move)] <- {
			// TODO: make sure this is correct by comparing to unreduced versions
			$0.symmetry = coord.symmetry + $0.symmetry
		}
	}
	
	private static func computeRepresentants() -> ([BaseCoord], [UInt16]) {
		measureTime(as: "computeRepresentants") {
			var representants: [BaseCoord] = []
			representants.reserveCapacity(BaseCoord.count / Symmetry.standardSubgroup.count)
			var classIndices: [UInt16] = .init(repeating: .max, count: BaseCoord.count)
			for coord in BaseCoord.allValues {
				guard classIndices[coord.intValue] == .max else { continue }
				
				// TODO: is there a way to just use the composing coords and their symmetry tables for this? probably not because permutation affects orientation…
				for symmetry in StandardSymmetry.all {
					classIndices[coord.shifted(with: symmetry).intValue] = .init(representants.endIndex)
				}
				
				representants.append(coord)
			}
			return (representants, classIndices)
		}
	}
}

extension ReducedFlipUDSliceCoordinate {
	init(index: Int, symmetryIndex: Int) {
		self.init(index: .init(index), symmetry: .init(index: symmetryIndex))
	}
	
	init<I>(_ value: I) where I : BinaryInteger {
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
	
	init(_ state: CubeTransformation.Edges) {
		self.init(BaseCoord(state))
	}
	
	func makeState() -> CubeTransformation.Edges {
		Self.representants[intValue]
			.shifted(with: symmetry.inverse)
			.makeState()
	}
}
