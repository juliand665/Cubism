import Foundation
import HandyOperators

protocol OrderedSubsetCoordinate: SimpleCoordinate, CoordinateWithMoveTable where CubeState: PiecePermutation {
	typealias Piece = CubeState.Piece
	
	static var subset: PieceSubset<CubeState> { get }
}

extension OrderedSubsetCoordinate {
	init(_ permutation: CubeState) {
		let subset = Self.subset
		let reframed = subset.shift(permutation)
		let invReframed = -reframed
		let digits = Piece.allCases.prefix(subset.included.count).reversed().map { piece in
			reframed.lazy
				.prefix(upTo: invReframed[piece].rawValue)
				.count { $0 > piece }
		}
		self.init(digits.sumWithIncreasingBases(firstBase: subset.excluded.count + 1))
	}
	
	func makeState() -> CubeState {
		let pieces: [Piece] = zip(digits(), Self.subset.included.reversed())
			.reduce(into: Self.subset.excluded) { positioned, next in
				positioned.insert(next.1, at: next.0)
			}
		return .init(array: pieces) - Self.subset.reframing
	}
	
	func apply(to state: inout CubeState) {
		var positions = Array(digits().reversed())
		// TODO: feels like there has to be a simpler solution lol
		for i in positions.indices {
			var minPos = positions[i]
			for j in i + 1..<positions.endIndex {
				if positions[j] >= minPos {
					positions[j] += 1
				} else {
					minPos -= 1
				}
			}
		}
		for (piece, position) in zip(Self.subset.included, positions) {
			let pos = Self.subset.reframing[position]
			state[pos] = piece
		}
	}
	
	func digits() -> [Int] {
		intValue.digitsWithIncreasingBases(
			count: Self.subset.included.count,
			firstBase: Self.subset.excluded.count + 1
		)
	}
	
	static func computeCount() -> Int {
		(subset.excluded.count + 1...Piece.allCases.count).reduce(1, *)
	}
}

struct OrderedUDSliceCoordinate: OrderedSubsetCoordinate {
	typealias CubeState = EdgePermutation
	
	static let subset = PieceSubset<EdgePermutation>(\.isPartOfUDSlice)
	static let count = computeCount()
	
	static let moveTable = FaceTurnMoveTable<Self>.cached().load()
	
	var value: UInt16
}

struct OrderedUFaceCoordinate: OrderedSubsetCoordinate {
	typealias CubeState = EdgePermutation
	
	static let subset = PieceSubset<EdgePermutation>(\.isPartOfUFace)
	static let count = computeCount()
	
	static let moveTable = FaceTurnMoveTable<Self>.cached().load()
	
	var value: UInt16
}

struct OrderedDFaceCoordinate: OrderedSubsetCoordinate {
	typealias CubeState = EdgePermutation
	
	static let subset = PieceSubset<EdgePermutation>(\.isPartOfDFace)
	static let count = computeCount()
	
	static let moveTable = FaceTurnMoveTable<Self>.cached().load()
	
	var value: UInt16
}

struct SubsettedEdgePermutationCoordinate: CoordinateWithMoves {
	typealias CubeState = EdgePermutation
	
	typealias UDSlice = OrderedUDSliceCoordinate
	typealias UFace = OrderedUFaceCoordinate
	typealias DFace = OrderedDFaceCoordinate
	
	static let count = UDSlice.count * UFace.count * DFace.count
	
	var udSlice: UDSlice
	var uFace: UFace
	var dFace: DFace
	
	var isZero: Bool {
		udSlice.isZero && uFace.isZero && dFace.isZero
	}
}

extension SubsettedEdgePermutationCoordinate {
	init(_ state: EdgePermutation) {
		udSlice = .init(state)
		uFace = .init(state)
		dFace = .init(state)
	}
	
	func makeState() -> EdgePermutation {
		.init() <- {
			udSlice.apply(to: &$0)
			uFace.apply(to: &$0)
			dFace.apply(to: &$0)
		}
	}
	
	var intValue: Int { fatalError() }
	
	init<I>(_ value: I) where I : BinaryInteger {
		fatalError()
	}
	
	var description: String {
		"\(Self.self)(\(udSlice), \(uFace), \(dFace))"
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		fatalError()
	}
	
	static func + (coord: Self, move: SolverMove) -> Self {
		.init(
			udSlice: coord.udSlice + move,
			uFace: coord.uFace + move,
			dFace: coord.dFace + move
		)
	}
}

struct PieceSubset<Permutation: PiecePermutation> {
	typealias Piece = Permutation.Piece
	
	let included: [Piece]
	let excluded: [Piece]
	/// remaps pieces such that the first pieces (in the canonical order) turn into the included list
	let reframing: Permutation
	let invReframing: Permutation
	
	init(_ includes: (Piece) -> Bool) {
		included = Piece.allCases.filter(includes)
		excluded = Piece.allCases.filter { !includes($0) }
		reframing = .init(array: included + excluded)
		invReframing = -reframing
	}
	
	func shift(_ permutation: Permutation) -> Permutation {
		invReframing + permutation + reframing
	}
}
