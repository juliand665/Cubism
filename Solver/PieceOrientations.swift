import Foundation

protocol PieceOrientations: PartialCubeState {
	associatedtype Orientation: PieceOrientation
	typealias Piece = Orientation.Piece
	associatedtype Space: CoordinateSpace
	
	subscript(piece: Piece) -> Orientation { get set }
	
	init()
	init(_ coordinate: Coordinate<Space>)
	init(array: [Orientation])
	
	func asArray() -> [Orientation]
	func coordinate() -> Coordinate<Space>
}

extension PieceOrientations {
	func coordinate() -> Coordinate<Space> {
		.init(
			asArray()
				.map(\.rawValue)
				.dropLast() // last is evident from the others
				.reduce(0) { $0 * Orientation.allCases.count + $1 }
		)
	}
	
	init(_ coordinate: Coordinate<Space>) {
		guard coordinate.value != 0 else {
			self = .zero
			return
		}
		
		self.init(
			array: Self.digits(of: coordinate)
				.map { Orientation(rawValue: $0)! }
		)
	}
	
	private static func digits(of coordinate: Coordinate<Space>) -> [Int] {
		let base = Orientation.allCases.count
		let digits = coordinate.intValue.digits(withBase: base)
		let parity = digits.sum() % base
		let lastPiece = (base - parity) % base
		let count = Piece.allCases.count
		let leadingZeroes = repeatElement(0, count: count - digits.count - 1)
		return leadingZeroes + digits + [lastPiece]
	}
}

/// defines for each spot which orientation its corner has relative to U/D
struct CornerOrientations: Hashable, PieceOrientations, TaggedCorners {
	typealias Tag = CornerOrientation
	typealias Space = CornerOrientationCoordinate.Space
	
	static let zero = Self()
	
	// TODO: flips?
	
	var urf = CornerOrientation.neutral
	var ufl = CornerOrientation.neutral
	var ulb = CornerOrientation.neutral
	var ubr = CornerOrientation.neutral
	
	var dfr = CornerOrientation.neutral
	var dlf = CornerOrientation.neutral
	var dbl = CornerOrientation.neutral
	var drb = CornerOrientation.neutral
	
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
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state.applying(transform.cornerPermutation) + transform.cornerOrientations
	}
}

/// defines for each spot which orientation its corner has relative to U/D
struct EdgeOrientations: Hashable, PieceOrientations, TaggedEdges {
	typealias Tag = EdgeOrientation
	typealias Space = EdgeOrientationCoordinate.Space
	
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
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state.applying(transform.edgePermutation) + transform.edgeOrientations
	}
}
