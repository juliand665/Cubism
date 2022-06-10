import Foundation

extension CubeTransformation {
	static let singleU = Self(
		cornerPermutation: .init(urf: .ubr, ufl: .urf, ulb: .ufl, ubr: .ulb),
		edgePermutation: .init(ur: .ub, uf: .ur, ul: .uf, ub: .ul)
	)
	
	static let singleD = Self(
		cornerPermutation: .init(dfr: .dlf, dlf: .dbl, dbl: .drb, drb: .dfr),
		edgePermutation: .init(dr: .df, df: .dl, dl: .db, db: .dr)
	)
	
	static let singleF = Self(
		cornerPermutation: .init(urf: .ufl, ufl: .dlf, dfr: .urf, dlf: .dfr),
		cornerOrientation: .init(urf: .twistedCW, ufl: .twistedCCW, dfr: .twistedCCW, dlf: .twistedCW),
		edgePermutation: .init(uf: .fl, df: .fr, fr: .uf, fl: .df),
		edgeOrientation: .init(uf: .flipped, df: .flipped, fr: .flipped, fl: .flipped)
	)
	
	static let singleB = Self(
		cornerPermutation: .init(ulb: .ubr, ubr: .drb, dbl: .ulb, drb: .dbl),
		cornerOrientation: .init(ulb: .twistedCW, ubr: .twistedCCW, dbl: .twistedCCW, drb: .twistedCW),
		edgePermutation: .init(ub: .br, db: .bl, bl: .ub, br: .db),
		edgeOrientation: .init(ub: .flipped, db: .flipped, bl: .flipped, br: .flipped)
	)
	
	static let singleR = Self(
		cornerPermutation: .init(urf: .dfr, ubr: .urf, dfr: .drb, drb: .ubr),
		cornerOrientation: .init(urf: .twistedCCW, ubr: .twistedCW, dfr: .twistedCW, drb: .twistedCCW),
		edgePermutation: .init(ur: .fr, dr: .br, fr: .dr, br: .ur)
	)
	
	static let singleL = Self(
		cornerPermutation: .init(ufl: .ulb, ulb: .dbl, dlf: .ufl, dbl: .dlf),
		cornerOrientation: .init(ufl: .twistedCW, ulb: .twistedCCW, dlf: .twistedCCW, dbl: .twistedCW),
		edgePermutation: .init(ul: .bl, dl: .fl, fl: .ul, bl: .dl)
	)
	
	static let symmetryURF3 = Self(
		cornerPermutation: .init(
			ufl: .dfr, ulb: .dlf, ubr: .ufl,
			dfr: .ubr, dlf: .drb, drb: .ulb
		),
		cornerOrientation: .init(
			urf: .twistedCW, ufl: .twistedCCW, ulb: .twistedCW, ubr: .twistedCCW,
			dfr: .twistedCCW, dlf: .twistedCW, dbl: .twistedCCW, drb: .twistedCW
		),
		edgePermutation: .init(
			ur: .uf, uf: .fr, ul: .df, ub: .fl,
			dr: .ub, df: .br, dl: .db, db: .bl,
			fr: .ur, fl: .dr, bl: .dl, br: .ul
		),
		edgeOrientation: .init(
			ur: .flipped, ul: .flipped, dr: .flipped, dl: .flipped,
			fr: .flipped, fl: .flipped, bl: .flipped, br: .flipped
		)
	)
	
	static let symmetryF2 = Self(
		cornerPermutation: .init(
			urf: .dlf, ufl: .dfr, ulb: .drb, ubr: .dbl,
			dfr: .ufl, dlf: .urf, dbl: .ubr, drb: .ulb
		),
		edgePermutation: .init(
			ur: .dl, uf: .df, ul: .dr, ub: .db,
			dr: .ul, df: .uf, dl: .ur, db: .ub,
			fr: .fl, fl: .fr, bl: .br, br: .bl
		)
	)
	
	static let symmetryU4 = Self(
		cornerPermutation: .init(
			urf: .ubr, ufl: .urf, ulb: .ufl, ubr: .ulb,
			dfr: .drb, dlf: .dfr, dbl: .dlf, drb: .dbl
		),
		edgePermutation: .init(
			ur: .ub, uf: .ur, ul: .uf, ub: .ul,
			dr: .db, df: .dr, dl: .df, db: .dl,
			fr: .br, fl: .fr, bl: .fl, br: .bl
		),
		edgeOrientation: .init(
			fr: .flipped, fl: .flipped, bl: .flipped, br: .flipped
		)
	)
	
	static let symmetryLR2 = Self(
		cornerPermutation: .init(
			urf: .ufl, ufl: .urf, ulb: .ubr, ubr: .ulb,
			dfr: .dlf, dlf: .dfr, dbl: .drb, drb: .dbl
		),
		cornerOrientation: .init(isFlipped: true),
		edgePermutation: .init(
			ur: .ul, ul: .ur,
			dr: .dl, dl: .dr,
			fr: .fl, fl: .fr, bl: .br, br: .bl
		)
	)
}

extension CubeTransformation {
	private static let urf3 = Symmetry(forward: .symmetryURF3)
	static let yRotation = CubeTransformation.symmetryU4
	static let zRotation = urf3.shift(yRotation)
	static let xRotation = urf3.shift(zRotation)
	
	static let wideU = +yRotation + singleD
	static let wideD = -yRotation + singleU
	static let wideR = +xRotation + singleL
	static let wideL = -xRotation + singleR
	static let wideF = +zRotation + singleB
	static let wideB = -zRotation + singleF
	
	static let sliceBehindD = wideD - singleD
	static let sliceBehindL = wideL - singleL
	static let sliceBehindF = wideF - singleF
}

extension CubeTransformation {
	static func transform(for face: Face) -> Self {
		switch face {
		case .front:
			return .singleF
		case .back:
			return .singleB
		case .up:
			return .singleU
		case .down:
			return .singleD
		case .left:
			return .singleL
		case .right:
			return .singleR
		}
	}
	
	static func transformForWideTurn(of face: Face) -> Self {
		switch face {
		case .front:
			return .wideF
		case .back:
			return .wideB
		case .up:
			return .wideU
		case .down:
			return .wideD
		case .left:
			return .wideL
		case .right:
			return .wideR
		}
	}
}
