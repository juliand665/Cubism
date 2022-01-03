/// Expresses anything you can do to the cube. Either interpreted as a transformation of the cube relative to another state, or as a state (a transformation relative to the solved state).
struct CubeTransformation: Hashable {
	var corners = Corners()
	var edges = Edges()
	
	struct Corners: PieceTransformation {
		var permutation = CornerPermutation()
		var orientation = CornerOrientation()
	}
	
	struct Edges: PieceTransformation {
		var permutation = EdgePermutation()
		var orientation = EdgeOrientation()
	}
}

protocol PieceTransformation: Hashable {}

extension CubeTransformation {
	init(
		cornerPermutation: CornerPermutation = .init(),
		cornerOrientation: CornerOrientation = .init(),
		edgePermutation: EdgePermutation = .init(),
		edgeOrientation: EdgeOrientation = .init()
	) {
		self.init(
			corners: .init(permutation: cornerPermutation, orientation: cornerOrientation),
			edges: .init(permutation: edgePermutation, orientation: edgeOrientation)
		)
	}
}

extension CubeTransformation: PartialCubeState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			corners: one.corners + two.corners,
			edges: one.edges + two.edges
		)
	}
	
	static prefix func - (t: Self) -> Self {
		.init(
			corners: -t.corners,
			edges: -t.edges
		)
	}
	
	static func get(from full: CubeTransformation) -> Self { full }
	
	func repeatedApplications(to start: Self? = nil) -> UnfoldSequence<Self, (Self?, Bool)> {
		sequence(first: start ?? self) { $0 + self }
	}
	
	func uniqueApplications() -> [Self] {
		repeatedApplications(to: self).prefix { $0 != .zero }
	}
}

extension CubeTransformation.Corners: PartialCornerState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			permutation: one.permutation + two,
			orientation: one.orientation + two
		)
	}
	
	static prefix func - (t: Self) -> Self {
		let inversePerm = -t.permutation
		return .init(
			permutation: inversePerm,
			orientation: -t.orientation.applying(inversePerm)
		)
	}
}

// TODO: unify with corners?
extension CubeTransformation.Edges: PartialEdgeState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			permutation: one.permutation + two,
			orientation: one.orientation + two
		)
	}
	
	static prefix func - (t: Self) -> Self {
		let inversePerm = -t.permutation
		return .init(
			permutation: inversePerm,
			orientation: -t.orientation.applying(inversePerm)
		)
	}
}

extension CubeTransformation {
	static let upTurn = Self(
		cornerPermutation: .init(urf: .ubr, ufl: .urf, ulb: .ufl, ubr: .ulb),
		edgePermutation: .init(ur: .ub, uf: .ur, ul: .uf, ub: .ul)
	)
	
	static let downTurn = Self(
		cornerPermutation: .init(dfr: .dlf, dlf: .dbl, dbl: .drb, drb: .dfr),
		edgePermutation: .init(dr: .df, df: .dl, dl: .db, db: .dr)
	)
	
	static let frontTurn = Self(
		cornerPermutation: .init(urf: .ufl, ufl: .dlf, dfr: .urf, dlf: .dfr),
		cornerOrientation: .init(urf: .twistedCW, ufl: .twistedCCW, dfr: .twistedCCW, dlf: .twistedCW),
		edgePermutation: .init(uf: .fl, df: .fr, fr: .uf, fl: .df),
		edgeOrientation: .init(uf: .flipped, df: .flipped, fr: .flipped, fl: .flipped)
	)
	
	static let backTurn = Self(
		cornerPermutation: .init(ulb: .ubr, ubr: .drb, dbl: .ulb, drb: .dbl),
		cornerOrientation: .init(ulb: .twistedCW, ubr: .twistedCCW, dbl: .twistedCCW, drb: .twistedCW),
		edgePermutation: .init(ub: .br, db: .bl, bl: .ub, br: .db),
		edgeOrientation: .init(ub: .flipped, db: .flipped, bl: .flipped, br: .flipped)
	)
	
	static let rightTurn = Self(
		cornerPermutation: .init(urf: .dfr, ubr: .urf, dfr: .drb, drb: .ubr),
		cornerOrientation: .init(urf: .twistedCCW, ubr: .twistedCW, dfr: .twistedCW, drb: .twistedCCW),
		edgePermutation: .init(ur: .fr, dr: .br, fr: .dr, br: .ur)
	)
	
	static let leftTurn = Self(
		cornerPermutation: .init(ufl: .ulb, ulb: .dbl, dlf: .ufl, dbl: .dlf),
		cornerOrientation: .init(ufl: .twistedCW, ulb: .twistedCCW, dlf: .twistedCCW, dbl: .twistedCW),
		edgePermutation: .init(ul: .bl, dl: .fl, fl: .ul, bl: .dl)
	)
	
	static func transform(for face: Face) -> Self {
		switch face {
		case .front:
			return .frontTurn
		case .back:
			return .backTurn
		case .up:
			return .upTurn
		case .down:
			return .downTurn
		case .left:
			return .leftTurn
		case .right:
			return .rightTurn
		}
	}
	
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
