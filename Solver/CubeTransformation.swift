import Foundation

/// Expresses anything you can do to the cube. Either interpreted as a transformation of the cube relative to another state, or as a state (a transformation relative to the solved state).
struct CubeTransformation: Hashable {
	var cornerPermutation = CornerPermutation()
	var cornerOrientations = CornerOrientations()
	var edgePermutation = EdgePermutation()
	var edgeOrientations = EdgeOrientations()
}

extension CubeTransformation: AdditiveArithmeticWithNegation {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			cornerPermutation: one.cornerPermutation + two.cornerPermutation,
			cornerOrientations: one.cornerOrientations.applying(two.cornerPermutation) + two.cornerOrientations,
			edgePermutation: one.edgePermutation + two.edgePermutation,
			edgeOrientations: one.edgeOrientations.applying(two.edgePermutation) + two.edgeOrientations
		)
	}
	
	static prefix func - (t: Self) -> Self {
		let inverseCorners = -t.cornerPermutation
		let inverseEdges = -t.edgePermutation
		return .init(
			cornerPermutation: inverseCorners,
			cornerOrientations: -t.cornerOrientations.applying(inverseCorners),
			edgePermutation: inverseEdges,
			edgeOrientations: -t.edgeOrientations.applying(inverseEdges)
		)
	}
}

extension CubeTransformation: TextOutputStreamable {
	func write<Target: TextOutputStream>(to target: inout Target) {
		guard self != .zero else {
			print("CubeTransformation.zero", terminator: "", to: &target)
			return
		}
		
		print("CubeTransformation(", to: &target)
		
		let lists: [[String]] = [
			Corner.allCases.compactMap {
				let new = cornerPermutation[$0]
				guard new != $0 else { return nil }
				return "\($0.name) ← \(new.name)"
			},
			Corner.allCases.compactMap {
				let orientation = cornerOrientations[$0]
				switch orientation {
				case .neutral:
					return nil
				case.twistedCW:
					return "\($0.name): cw"
				case.twistedCCW:
					return "\($0.name): ccw"
				}
			},
			Edge.allCases.compactMap {
				let new = edgePermutation[$0]
				guard new != $0 else { return nil }
				return "\($0.name) ← \(new.name)"
			},
			Edge.allCases.compactMap {
				let orientation = edgeOrientations[$0]
				guard orientation != .neutral else { return nil }
				return "\($0.name): flipped"
			},
		]
		for list in lists where !list.isEmpty {
			print("\t" + list.joined(separator: ", "), to: &target)
		}
		
		print(")", terminator: "", to: &target)
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
		cornerOrientations: .init(urf: .twistedCW, ufl: .twistedCCW, dfr: .twistedCCW, dlf: .twistedCW),
		edgePermutation: .init(uf: .fl, df: .fr, fr: .uf, fl: .df),
		edgeOrientations: .init(uf: .flipped, df: .flipped, fr: .flipped, fl: .flipped)
	)
	
	static let backTurn = Self(
		cornerPermutation: .init(ulb: .ubr, ubr: .drb, dbl: .ulb, drb: .dbl),
		cornerOrientations: .init(ulb: .twistedCW, ubr: .twistedCCW, dbl: .twistedCCW, drb: .twistedCW),
		edgePermutation: .init(ub: .br, db: .bl, bl: .ub, br: .db),
		edgeOrientations: .init(ub: .flipped, db: .flipped, bl: .flipped, br: .flipped)
	)
	
	static let rightTurn = Self(
		cornerPermutation: .init(urf: .dfr, ubr: .urf, dfr: .drb, drb: .ubr),
		cornerOrientations: .init(urf: .twistedCCW, ubr: .twistedCW, dfr: .twistedCW, drb: .twistedCCW),
		edgePermutation: .init(ur: .fr, dr: .br, fr: .dr, br: .ur)
	)
	
	static let leftTurn = Self(
		cornerPermutation: .init(ufl: .ulb, ulb: .dbl, dlf: .ufl, dbl: .dlf),
		cornerOrientations: .init(ufl: .twistedCW, ulb: .twistedCCW, dlf: .twistedCCW, dbl: .twistedCW),
		edgePermutation: .init(ul: .bl, dl: .fl, fl: .ul, bl: .dl)
	)
}
