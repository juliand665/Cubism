import HandyOperators
import Algorithms

protocol PiecePermutation: PartialCubeStateWithCoord {
	associatedtype Piece: Comparable, CaseIterable
	where Piece.AllCases: RandomAccessCollection
	
	subscript(piece: Piece) -> Piece { get set }
	
	init()
	init(array: [Piece])
	
	func asArray() -> [Piece]
}

extension PiecePermutation {
	func coordinate() -> Coord {
		asArray().permutationCoordinate()
	}
	
	init(_ coordinate: Coord) {
		guard coordinate.value != 0 else {
			self = .zero
			return
		}
		
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
	typealias Coord = CornerPermutationCoordinate
	
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
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state + transform.cornerPermutation
	}
	
	static func + (transform: CubeTransformation, state: Self) -> Self {
		transform.cornerPermutation + state
	}
}

/// defines for each spot what edge it receives
struct EdgePermutation: Hashable, PiecePermutation, TaggedEdges {
	typealias Tag = Edge
	typealias Coord = EdgePermutationCoordinate
	
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
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state + transform.edgePermutation
	}
	
	static func + (transform: CubeTransformation, state: Self) -> Self {
		transform.edgePermutation + state
	}
}

extension RandomAccessCollection where Element: Comparable {
	func permutationCoordinate<Coord: Coordinate>() -> Coord {
		.init(
			self
				.indexed()
				.map { (index, piece) in
					prefix(upTo: index).count { $0 > piece }
				}
				.sumWithIncreasingBases()
		)
	}
	
	func reorderedToMatch<Coord: Coordinate>(_ coordinate: Coord) -> [Element] {
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
