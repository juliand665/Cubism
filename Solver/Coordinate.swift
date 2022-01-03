import Foundation
import HandyOperators

struct Coordinate<Space: CoordinateSpace>: Hashable, Comparable {
	typealias Space = Space // make generic arg accessible as member
	
	static var allValues: LazyMapSequence<Range<Space.Value>, Self> {
		(0..<Space.count).lazy.map(Self.init)
	}
	
	var value: Space.Value
	
	var intValue: Int { Int(value) }
	
	init<I: BinaryInteger>(_ value: I) {
		self.value = .init(value)
		assert(value < Space.count)
	}
	
	init(_ state: Space.CubeState) {
		self = Space.makeCoordinate(from: state)
	}
	
	func makeState() -> Space.CubeState {
		Space.makeState(from: self)
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.value < rhs.value
	}
}

extension Coordinate where Space: CoordinateSpaceWithSymmetryTable {
	var standardSymmetries: [Self] {
		Space.standardSymmetryTable[self].moves
	}
}

protocol CoordinateSpace {
	associatedtype CubeState: PartialCubeState
	associatedtype Value: BinaryInteger where Value.Stride: SignedInteger
	typealias Coord = Coordinate<Self>
	
	static var count: Value { get }
	static var validSymmetries: [Symmetry] { get }
	
	static func makeState(from coordinate: Coord) -> CubeState
	static func makeCoordinate(from state: CubeState) -> Coord
}

extension CoordinateSpace {
	static var validSymmetries: [Symmetry] { Symmetry.standardSubgroup }
}

protocol CoordinateSpaceWithSymmetryTable: CoordinateSpace {
	static var standardSymmetryTable: StandardSymmetryTable<Self> { get }
}

protocol CoordinateSpaceWithMoves: CoordinateSpace {
	static func applyMove(_ move: SolverMove, to coord: Coord) -> Coord
}

extension Coordinate where Space: CoordinateSpaceWithMoves {
	static func + (coord: Self, move: SolverMove) -> Self {
		Space.applyMove(move, to: coord)
	}
}

protocol CoordinateSpaceWithMoveTable: CoordinateSpaceWithMoves {
	static var moveTable: FaceTurnMoveTable<Self> { get }
}

extension CoordinateSpaceWithMoveTable {
	static func applyMove(_ move: SolverMove, to coord: Coord) -> Coord {
		moveTable[coord][move]
	}
}

typealias CornerOrientationCoordinate = Coordinate<_CornerOrientationCoordinateSpace>
struct _CornerOrientationCoordinateSpace: CoordinateSpaceWithMoveTable, CoordinateSpaceWithSymmetryTable {
	static let count: UInt16 = 2187 // 3^7
	
	static let moveTable = FaceTurnMoveTable<Self>()
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	static func makeState(from coordinate: Coord) -> CornerOrientation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: CornerOrientation) -> Coord {
		state.coordinate()
	}
}

typealias EdgeOrientationCoordinate = Coordinate<_EdgeOrientationCoordinateSpace>
struct _EdgeOrientationCoordinateSpace: CoordinateSpaceWithSymmetryTable {
	static let count: UInt16 = 2048 // 2^11
	
	static let validSymmetries = Symmetry.edgeFlipPreservingSubgroup
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	static func makeState(from coordinate: Coord) -> EdgeOrientation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgeOrientation) -> Coord {
		state.coordinate()
	}
}

typealias CornerPermutationCoordinate = Coordinate<_CornerPermutationCoordinateSpace>
struct _CornerPermutationCoordinateSpace: CoordinateSpace {
	static let count: UInt16 = 40_320 // 8!
	
	static func makeState(from coordinate: Coord) -> CornerPermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: CornerPermutation) -> Coord {
		state.coordinate()
	}
}

typealias EdgePermutationCoordinate = Coordinate<_EdgePermutationCoordinateSpace>
struct _EdgePermutationCoordinateSpace: CoordinateSpace {
	static let count: UInt32 = 479_001_600 // 12!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.coordinate()
	}
}

/// Describes where the 4 edges belonging in the UD slice are currently, ignoring order.
typealias UDSliceCoordinate = Coordinate<_UDSliceCoordinateSpace>
struct _UDSliceCoordinateSpace: CoordinateSpaceWithSymmetryTable {
	static let count: UInt16 = 495 // nCr(12, 8)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		.init(coordinate)
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.udSliceCoordinate()
	}
}

/// Combines the UD slice coordinate with the edge orientation (flip).
typealias FlipUDSliceCoordinate = Coordinate<_FlipUDSliceCoordinateSpace>
struct _FlipUDSliceCoordinateSpace: CoordinateSpaceWithSymmetryTable {
	static let count = UInt32(UDSliceCoordinate.Space.count) * UInt32(EdgeOrientationCoordinate.Space.count)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	static func makeState(from coordinate: Coord) -> CubeTransformation {
		let (udSlice, orientation) = coordinate.components
		return .init(
			edgePermutation: udSlice.makeState(),
			edgeOrientation: orientation.makeState()
		)
	}
	
	static func makeCoordinate(from state: CubeTransformation) -> Coord {
		.init(state.edgePermutation, state.edgeOrientation)
	}
}

extension FlipUDSliceCoordinate {
	var components: (udSlice: UDSliceCoordinate, orientation: EdgeOrientationCoordinate) {
		let (udSlice, orientation) = value.quotientAndRemainder(dividingBy: .init(EdgeOrientationCoordinate.Space.count))
		return (.init(udSlice), .init(orientation))
	}
	
	init(_ permutation: EdgePermutation, _ orientation: EdgeOrientation) {
		self.init(permutation.udSliceCoordinate(), orientation.coordinate())
	}
	
	init(_ udSlice: UDSliceCoordinate, _ orientation: EdgeOrientationCoordinate) {
		value = .init(udSlice.value) * .init(EdgeOrientationCoordinate.Space.count) + .init(orientation.value)
	}
}

/// Same as `FlipUDSliceCoordinate`, except that it's been reduced using symmetries.
typealias ReducedFlipUDSliceCoordinate = Coordinate<_ReducedFlipUDSliceCoordinateSpace>
struct _ReducedFlipUDSliceCoordinateSpace: CoordinateSpaceWithMoveTable {
	typealias BaseCoord = FlipUDSliceCoordinate
	
	static let count = UInt32(representants.count)
	static let moveTable = FaceTurnMoveTable<Self>()
	
	// need to track symmetry index alongside equivalence class index, probably best to separate out notion of sym-coord from raw-coord
	
	static let (representants, symmetryToRepresentant) = computeRepresentants()
	
	private static func computeRepresentants() -> ([BaseCoord], [StandardSymmetry]) {
		measureTime(as: "computeRepresentants") {
			var representants: [BaseCoord] = []
			let baseCount = Int(BaseCoord.Space.count)
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
	
	static func makeState(from coordinate: Coord) -> CubeTransformation {
		representants[coordinate.intValue].makeState()
	}
	
	static func makeCoordinate(from state: CubeTransformation) -> Coord {
		//let udSlice = state.edgePermutation.udSliceCoordinate()
		//let orientation = state.edgeOrientation.coordinate()
		// apply all symmetries and find minimum coordinate
		//let representant = zip(udSlice.standardSymmetries, orientation.standardSymmetries)
		//	.min { $0.0 < $1.0 || $0.0 == $1.0 && $0.1 < $1.1 }! // tuples aren't comparable yet zzz
		//let baseCoord = BaseCoord(representant.0, representant.1)
		let coord = FlipUDSliceCoordinate(state)
		let baseCoord = coord.standardSymmetries.min()!
		return .init(representants.binarySearch(for: baseCoord)!)
	}
}

typealias Phase1Coordinate = Coordinate<_Phase1CoordinateSpace>
struct _Phase1CoordinateSpace: CoordinateSpaceWithMoves {
	static let count = UInt32(CornerOrientationCoordinate.Space.count)
	* ReducedFlipUDSliceCoordinate.Space.count
	
	static func makeState(from coordinate: Coord) -> CubeTransformation {
		let (reduced, corners) = coordinate.components
		
		return reduced.makeState() <- {
			$0.cornerOrientation = corners.makeState()
		}
	}
	
	static func makeCoordinate(from state: CubeTransformation) -> Coord {
		.init(.init(state), .init(state.cornerOrientation))
	}
	
	static func applyMove(_ move: SolverMove, to coord: Coord) -> Coord {
		let (reduced, corners) = coord.components
		//let newReduced = reduced + move
		//let oldSym = ReducedFlipUDSliceCoordinate.Space.symmetryToRepresentant[]
		return .init(reduced + move, corners + move)
	}
}

extension Phase1Coordinate {
	var components: (reduced: ReducedFlipUDSliceCoordinate, corners: CornerOrientationCoordinate) {
		let (reduced, corners) = value.quotientAndRemainder(dividingBy: .init(CornerOrientationCoordinate.Space.count))
		return (.init(reduced), .init(corners))
	}
	
	init(_ reduced: ReducedFlipUDSliceCoordinate, _ corners: CornerOrientationCoordinate) {
		value = reduced.value * .init(CornerOrientationCoordinate.Space.count) + .init(corners.value)
	}
}

/// For phase 2. Describes how the 4 UD slice edges are permuted, assuming they're within their slice.
typealias SliceEdgePermutationCoordinate = Coordinate<_SliceEdgePermutationCoordinateSpace>
struct _SliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count: UInt8 = 24 // 4!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		fatalError("TODO")
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.sliceEdgePermCoordinate()
	}
}

/// For phase 2. Describes how the 8 non-UD slice edges are permuted, assuming they're outside the slice.
typealias NonSliceEdgePermutationCoordinate = Coordinate<_NonSliceEdgePermutationCoordinateSpace>
struct _NonSliceEdgePermutationCoordinateSpace: CoordinateSpace {
	static let count: UInt16 = 40_320 // 8!
	
	static func makeState(from coordinate: Coord) -> EdgePermutation {
		fatalError("TODO")
	}
	
	static func makeCoordinate(from state: EdgePermutation) -> Coord {
		state.nonSliceEdgePermCoordinate()
	}
}
