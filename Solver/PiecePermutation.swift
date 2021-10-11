import Foundation
import HandyOperators
import Algorithms

protocol PiecePermutation: AdditiveArithmeticWithNegation {
	associatedtype Piece: Comparable, CaseIterable
	where Piece.AllCases: RandomAccessCollection
	associatedtype Space: CoordinateSpace
	
	subscript(piece: Piece) -> Piece { get set }
	
	init()
	init(array: [Piece])
	
	func asArray() -> [Piece]
	func coordinate() -> Coordinate<Space>
}

extension PiecePermutation {
	func coordinate() -> Coordinate<Space> {
		asArray().permutationCoordinate()
	}
	
	init(coordinate: Coordinate<Space>) {
		self.init(array: Piece.allCases.reorderedToMatch(coordinate))
	}
	
	static prefix func - (perm: Self) -> Self {
		.init() <- {
			for piece in Piece.allCases {
				$0[perm[piece]] = piece
			}
		}
	}
}

/// defines for each spot what corner it receives
struct CornerPermutation: Hashable, PiecePermutation, TaggedCorners {
	typealias Tag = Corner
	typealias Space = CornerPermutationCoordinate.Space
	
	static let zero = Self()
	
	var urf = Corner.urf
	var ufl = Corner.ufl
	var ulb = Corner.ulb
	var ubr = Corner.ubr
	
	var dfr = Corner.dfr
	var dlf = Corner.dlf
	var dbl = Corner.dbl
	var drb = Corner.drb
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			urf: one[two.urf],
			ufl: one[two.ufl],
			ulb: one[two.ulb],
			ubr: one[two.ubr],
			
			dfr: one[two.dfr],
			dlf: one[two.dlf],
			dbl: one[two.dbl],
			drb: one[two.drb]
		)
	}
}

/// defines for each spot what edge it receives
struct EdgePermutation: Hashable, PiecePermutation, TaggedEdges {
	typealias Tag = Edge
	typealias Space = EdgePermutationCoordinate.Space
	
	static let zero = Self()
	
	var ur = Edge.ur
	var uf = Edge.uf
	var ul = Edge.ul
	var ub = Edge.ub
	
	var dr = Edge.dr
	var df = Edge.df
	var dl = Edge.dl
	var db = Edge.db
	
	var fr = Edge.fr
	var fl = Edge.fl
	var bl = Edge.bl
	var br = Edge.br
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			ur: one[two.ur],
			uf: one[two.uf],
			ul: one[two.ul],
			ub: one[two.ub],
			
			dr: one[two.dr],
			df: one[two.df],
			dl: one[two.dl],
			db: one[two.db],
			
			fr: one[two.fr],
			fl: one[two.fl],
			bl: one[two.bl],
			br: one[two.br]
		)
	}
	
	func udSliceCoordinate() -> UDSliceCoordinate {
		let state = asArray()
			.enumerated()
			.reduce(into: (sum: 0, coefficient: 0, k: -1)) { state, new in
				// a complex-looking way to improve performance by avoiding lots of factorial calculations and counting occupied spots in the process
				let edge = new.element
				let n = new.offset
				
				state.coefficient *= n
				if edge.isPartOfUDSlice {
					state.k += 1
					if state.k == 0 {
						state.coefficient = 1
					} else {
						state.coefficient /= state.k
					}
				} else {
					state.coefficient /= n - state.k
					
					if state.k >= 0 {
						state.sum += state.coefficient
					}
				}
			}
		
		assert(state.coefficient == 165) // nCr(11, 3)
		assert(state.k == 3)
		return .init(state.sum)
	}
	
	func sliceEdgePermCoordinate() -> SliceEdgePermutationCoordinate {
		asArray()
			.filter { $0.isPartOfUDSlice }
			.permutationCoordinate()
	}
	
	func nonSliceEdgePermCoordinate() -> NonSliceEdgePermutationCoordinate {
		asArray()
			.filter { !$0.isPartOfUDSlice }
			.permutationCoordinate()
	}
}

extension RandomAccessCollection where Element: Comparable {
	func permutationCoordinate<S: CoordinateSpace>() -> Coordinate<S> {
		.init(
			self
				.indexed()
				.map { (index, piece) in
					prefix(upTo: index).count { $0 > piece }
				}
				.sumWithIncreasingBases()
		)
	}
	
	func reorderedToMatch<S: CoordinateSpace>(_ coordinate: Coordinate<S>) -> [Element] {
		coordinate.intValue
			.digitsWithIncreasingBases(count: count)
			.reversed()
			.map(state: reversed()) { $0.remove(at: $1) }
			.reversed()
	}
}

extension Edge {
	var isPartOfUDSlice: Bool {
		switch self {
		case .fr, .fl, .bl, .br:
			return true
		default:
			return false
		}
	}
}
