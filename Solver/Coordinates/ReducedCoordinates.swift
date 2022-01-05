// these coordinates take a base coord and reduce it into (less) equivalence classes through symmetries

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
struct ReducedFlipUDSliceCoordinate: CoordinateWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let count = UInt16(representants.count)
	static let moveTable = FaceTurnMoveTable<Self>()
	
	// need to track symmetry index alongside equivalence class index, probably best to separate out notion of sym-coord from raw-coord
	
	static let (representants, symmetryToRepresentant) = computeRepresentants()
	
	var value: UInt16
	
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
	init(_ state: CubeTransformation.Edges) {
		//let udSlice = state.edgePermutation.udSliceCoordinate()
		//let orientation = state.edgeOrientation.coordinate()
		// apply all symmetries and find minimum coordinate
		//let representant = zip(udSlice.standardSymmetries, orientation.standardSymmetries)
		//	.min { $0.0 < $1.0 || $0.0 == $1.0 && $0.1 < $1.1 }! // tuples aren't comparable yet zzz
		//let baseCoord = BaseCoord(representant.0, representant.1)
		let coord = FlipUDSliceCoordinate(state)
		let baseCoord = coord.standardSymmetries.min()!
		self.init(Self.representants.binarySearch(for: baseCoord)!)
	}
	
	func makeState() -> CubeTransformation.Edges {
		Self.representants[intValue].makeState()
	}
}
