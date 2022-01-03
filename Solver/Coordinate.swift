import Foundation
import HandyOperators

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

extension Coordinate where CubeState: SimplePartialCubeState, CubeState.Coord == Self {
	init(_ state: CubeState) {
		self = state.coordinate()
	}
	
	func makeState() -> CubeState {
		.init(self)
	}
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

/// Describes where the 4 edges belonging in the UD slice are currently, ignoring order.
struct UDSliceCoordinate: CoordinateWithSymmetryTable {
	typealias CubeState = EdgePermutation
	
	static let count: UInt16 = 495 // nCr(12, 8)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt16
}

extension UDSliceCoordinate {
	init(_ state: EdgePermutation) {
		self = state.udSliceCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		.init(self)
	}
}

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
	
	init(_ state: CubeTransformation) {
		self.init(state.edgePermutation, state.edgeOrientation)
	}
	
	func makeState() -> CubeTransformation {
		let (udSlice, orientation) = components
		return .init(
			edgePermutation: udSlice.makeState(),
			edgeOrientation: orientation.makeState()
		)
	}
}

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
struct ReducedFlipUDSliceCoordinate: CoordinateWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let count = UInt32(representants.count)
	static let moveTable = FaceTurnMoveTable<Self>()
	
	// need to track symmetry index alongside equivalence class index, probably best to separate out notion of sym-coord from raw-coord
	
	static let (representants, symmetryToRepresentant) = computeRepresentants()
	
	var value: UInt32
	
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
	init(_ state: CubeTransformation) {
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
	
	func makeState() -> CubeTransformation {
		Self.representants[intValue].makeState()
	}
}

struct Phase1Coordinate: CoordinateWithMoves {
	static let count = UInt32(CornerOrientationCoordinate.count) * ReducedFlipUDSliceCoordinate.count
	
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
		value = reduced.value * .init(CornerOrientationCoordinate.count) + .init(corners.value)
	}
	
	init(_ state: CubeTransformation) {
		self.init(.init(state), .init(state.cornerOrientation))
	}
	
	func makeState() -> CubeTransformation {
		let (reduced, corners) = components
		
		return reduced.makeState() <- {
			$0.cornerOrientation = corners.makeState()
		}
	}
}

/// For phase 2. Describes how the 4 UD slice edges are permuted, assuming they're within their slice.
struct SliceEdgePermutationCoordinate: Coordinate {
	static let count: UInt8 = 24 // 4!
	
	var value: UInt8
}

extension SliceEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		self = state.sliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		fatalError("TODO")
	}
}

/// For phase 2. Describes how the 8 non-UD slice edges are permuted, assuming they're outside the slice.
struct NonSliceEdgePermutationCoordinate: Coordinate {
	static let count: UInt16 = 40_320 // 8!
	
	var value: UInt16
}

extension NonSliceEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		self = state.nonSliceEdgePermCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		fatalError("TODO")
	}
}
