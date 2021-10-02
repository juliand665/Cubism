import Foundation

protocol PieceOrientations: AdditiveArithmeticWithNegation {
	associatedtype Orientation: RawRepresentable, CaseIterable where Orientation.RawValue == Int
	
	func asArray() -> [Orientation]
	func coordinate() -> Int
}

extension PieceOrientations {
	func coordinate() -> Int {
		asArray()
			.map(\.rawValue)
			.dropLast() // last is evident from the others
			.reduce(0) { $0 * Orientation.allCases.count + $1 }
	}
}

/// defines for each spot which orientation its corner has relative to U/D
struct CornerOrientations: Hashable, PieceOrientations {
	static let possibilities = 2187 // 3^7
	static let zero = Self()
	
	var urf = CornerOrientation.neutral
	var ufl = CornerOrientation.neutral
	var ulb = CornerOrientation.neutral
	var ubr = CornerOrientation.neutral
	
	var dfr = CornerOrientation.neutral
	var dlf = CornerOrientation.neutral
	var dbl = CornerOrientation.neutral
	var drb = CornerOrientation.neutral
	
	subscript(corner: Corner) -> CornerOrientation {
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
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			urf: one.urf + two.urf,
			ufl: one.ufl + two.ufl,
			ulb: one.ulb + two.ulb,
			ubr: one.ubr + two.ubr,
			
			dfr: one.dfr + two.dfr,
			dlf: one.dlf + two.dlf,
			dbl: one.dbl + two.dbl,
			drb: one.drb + two.drb
		)
	}
	
	static prefix func - (o: Self) -> Self {
		.init(
			urf: -o.urf,
			ufl: -o.ufl,
			ulb: -o.ulb,
			ubr: -o.ubr,
			
			dfr: -o.dfr,
			dlf: -o.dlf,
			dbl: -o.dbl,
			drb: -o.drb
		)
	}
	
	func applying(_ perm: CornerPermutation) -> Self {
		.init(
			urf: self[perm.urf],
			ufl: self[perm.ufl],
			ulb: self[perm.ulb],
			ubr: self[perm.ubr],
			
			dfr: self[perm.dfr],
			dlf: self[perm.dlf],
			dbl: self[perm.dbl],
			drb: self[perm.drb]
		)
	}
	
	func asArray() -> [CornerOrientation] {
		[urf, ufl, ulb, ubr, dfr, dlf, dbl, drb]
	}
}

/// defines for each spot which orientation its corner has relative to U/D
struct EdgeOrientations: Hashable, PieceOrientations {
	static let possibilities = 2048 // 2^11
	static let zero = Self()
	
	var ur = EdgeOrientation.neutral
	var uf = EdgeOrientation.neutral
	var ul = EdgeOrientation.neutral
	var ub = EdgeOrientation.neutral
	
	var dr = EdgeOrientation.neutral
	var df = EdgeOrientation.neutral
	var dl = EdgeOrientation.neutral
	var db = EdgeOrientation.neutral
	
	var fr = EdgeOrientation.neutral
	var fl = EdgeOrientation.neutral
	var bl = EdgeOrientation.neutral
	var br = EdgeOrientation.neutral
	
	subscript(edge: Edge) -> EdgeOrientation {
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
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			ur: one.ur + two.ur,
			uf: one.uf + two.uf,
			ul: one.ul + two.ul,
			ub: one.ub + two.ub,
			
			dr: one.dr + two.dr,
			df: one.df + two.df,
			dl: one.dl + two.dl,
			db: one.db + two.db,
			
			fr: one.fr + two.fr,
			fl: one.fl + two.fl,
			bl: one.bl + two.bl,
			br: one.br + two.br
		)
	}
	
	static prefix func - (o: Self) -> Self { o } // edge orientations are their own inverse
	
	func applying(_ perm: EdgePermutation) -> Self {
		.init(
			ur: self[perm.ur],
			uf: self[perm.uf],
			ul: self[perm.ul],
			ub: self[perm.ub],
			
			dr: self[perm.dr],
			df: self[perm.df],
			dl: self[perm.dl],
			db: self[perm.db],
			
			fr: self[perm.fr],
			fl: self[perm.fl],
			bl: self[perm.bl],
			br: self[perm.br]
		)
	}
	
	func asArray() -> [EdgeOrientation] {
		[ur, uf, ul, ub, dr, df, dl, db, fr, fl, bl, br]
	}
}
