import HandyOperators

// these coordinates take a base coord and reduce it into (less) equivalence classes through symmetries

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
struct ReducedFlipUDSliceCoordinate: Coordinate, CoordinateWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let count = representants.count
	static let moveTable = FaceTurnMoveTable<Self>()
	
	static let (representants, symmetryToRepresentant) = computeRepresentants()
	
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
	
	private static func computeRepresentants() -> ([BaseCoord], [StandardSymmetry]) {
		measureTime(as: "computeRepresentants") {
			var representants: [BaseCoord] = []
			let baseCount = Int(BaseCoord.count)
			representants.reserveCapacity(baseCount / Symmetry.standardSubgroup.count)
			var symmetryToRepresentant: [StandardSymmetry?] = .init(repeating: nil, count: baseCount)
			for coord in BaseCoord.allValues {
				guard symmetryToRepresentant[coord.intValue] == nil else { continue }
				
				// TODO: is there a way to just use the coords and their symmetry tables for this? probably not because permutation affects orientation…
				let symmetries = coord.standardSymmetries
				for (index, symmetry) in symmetries.enumerated() {
					symmetryToRepresentant[symmetry.intValue] = .init(index: index)
				}
				
				representants.append(coord)
			}
			return (representants, symmetryToRepresentant.map { $0! })
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
		let (symIndex, baseCoord) = baseCoord.standardSymmetries.indexed().min { $0.element < $1.element }!
		self.init(index: Self.representants.binarySearch(for: baseCoord)!, symmetryIndex: symIndex)
	}
	
	init(_ state: CubeTransformation.Edges) {
		self.init(BaseCoord(state))
	}
	
	func makeState() -> CubeTransformation.Edges {
		Self.representants[intValue]
			.standardSymmetries[symmetry.inverse.index]
			.makeState()
	}
}
