import HandyOperators

protocol PiecePermutation: PartialCubeStateWithCoord, TaggedPieces where Tag == Piece {
	init()
}

extension PiecePermutation {
	func coordinate() -> Coord {
		permutationCoordinate()
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
	
	func cycles() -> [[Piece]] {
		var handled: Set<Piece> = []
		var cycles: [[Piece]] = []
		for piece in Piece.allCases where !handled.contains(piece) {
			handled.insert(piece)
			let target = self[piece]
			guard target != piece else { continue }
			let cycle: [Piece] = sequence(first: target) { self[$0] }
				.prefix { $0 != piece }
				.reversed()
			handled.formUnion(cycle)
			cycles.append([piece] + cycle)
		}
		return cycles
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
	
	static func + (state: Self, corners: CubeTransformation.Corners) -> Self {
		state + corners.permutation
	}
	
	static func + (corners: CubeTransformation.Corners, state: Self) -> Self {
		corners.permutation + state
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
	
	static func + (state: Self, edges: CubeTransformation.Edges) -> Self {
		state + edges.permutation
	}
	
	static func + (edges: CubeTransformation.Edges, state: Self) -> Self {
		edges.permutation + state
	}
}

extension RandomAccessCollection where Element: Comparable {
	var permutationParity: Int {
		self
			.indexed()
			.lazy
			.map { (index, piece) in
				prefix(upTo: index).count { $0 > piece }
			}
			.reduce(0, ^) & 1
	}
	
	func permutationCoordinate<Coord: Coordinate>() -> Coord {
		.init(
			self
				.indexed()
				.lazy
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
	
	var isPartOfUFace: Bool {
		switch self {
		case .ur, .uf, .ul, .ub:
			return true
		default:
			return false
		}
	}
	
	var isPartOfDFace: Bool {
		switch self {
		case .dr, .df, .dl, .db:
			return true
		default:
			return false
		}
	}
}
