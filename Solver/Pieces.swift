import Foundation

enum Corner: Comparable, CaseIterable {
	case urf, ufl, ulb, ubr
	case dfr, dlf, dbl, drb
	
	var name: String {
		String(describing: self).uppercased()
	}
}

enum Edge: Comparable, CaseIterable {
	case ur, uf, ul, ub
	case dr, df, dl, db
	case fr, fl, bl, br
	
	var name: String {
		String(describing: self).uppercased()
	}
}

enum Symmetry: Int, CaseIterable {
	/// 120° rotation through URF corner
	case urf3
	/// 180° rotation through F face
	case f2
	/// 90° rotation through U face
	case u4
	/// left-right flip
	case lr2
}
