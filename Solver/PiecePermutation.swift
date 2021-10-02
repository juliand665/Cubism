import Foundation
import HandyOperators

protocol PiecePermutation: AdditiveArithmeticWithNegation {
	associatedtype Piece: Comparable, CaseIterable
	
	subscript(piece: Piece) -> Piece { get set }
	
	init()
	
	func asArray() -> [Piece]
	func coordinate() -> Int
}

extension PiecePermutation {
	func coordinate() -> Int {
		let array = asArray()
		return array
			.enumerated()
			.map { (index, piece) in
				array.prefix(upTo: index).count { $0 > piece }
			}
			.enumerated()
			.reduce(into: (sum: 0, base: 1)) { state, new in
				state.sum += new.element * state.base
				state.base *= new.offset + 1
			}
			.sum
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
struct CornerPermutation: Hashable, PiecePermutation {
	static let possibilities = 40_320 // 8!
	static let zero = Self()
	
	var urf = Corner.urf
	var ufl = Corner.ufl
	var ulb = Corner.ulb
	var ubr = Corner.ubr
	
	var dfr = Corner.dfr
	var dlf = Corner.dlf
	var dbl = Corner.dbl
	var drb = Corner.drb
	
	subscript(corner: Corner) -> Corner {
		get {
			switch corner {
			case .urf: return urf
			case .ufl: return ufl
			case .ulb: return ulb
			case .ubr: return ubr
				
			case .dfr: return dfr
			case .dlf: return dlf
			case .dbl: return dbl
			case .drb: return drb
			}
		}
		set {
			switch corner {
			case .urf: urf = newValue
			case .ufl: ufl = newValue
			case .ulb: ulb = newValue
			case .ubr: ubr = newValue
				
			case .dfr: dfr = newValue
			case .dlf: dlf = newValue
			case .dbl: dbl = newValue
			case .drb: drb = newValue
			}
		}
	}
	
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
	
	func asArray() -> [Corner] {
		[urf, ufl, ulb, ubr, dfr, dlf, dbl, drb]
	}
}

/// defines for each spot what edge it receives
struct EdgePermutation: Hashable, PiecePermutation {
	static let possibilities = 479_001_600 // 12!
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
	
	subscript(edge: Edge) -> Edge {
		get {
			switch edge {
			case .ur: return ur
			case .uf: return uf
			case .ul: return ul
			case .ub: return ub
				
			case .dr: return dr
			case .df: return df
			case .dl: return dl
			case .db: return db
				
			case .fr: return fr
			case .fl: return fl
			case .bl: return bl
			case .br: return br
			}
		}
		set {
			switch edge {
			case .ur: ur = newValue
			case .uf: uf = newValue
			case .ul: ul = newValue
			case .ub: ub = newValue
				
			case .dr: dr = newValue
			case .df: df = newValue
			case .dl: dl = newValue
			case .db: db = newValue
				
			case .fr: fr = newValue
			case .fl: fl = newValue
			case .bl: bl = newValue
			case .br: br = newValue
			}
		}
	}
	
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
	
	func asArray() -> [Edge] {
		[ur, uf, ul, ub, dr, df, dl, db, fr, fl, bl, br]
	}
}
