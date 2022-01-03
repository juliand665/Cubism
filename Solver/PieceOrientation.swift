protocol PieceOrientation: PartialCubeStateWithCoord {
	associatedtype Orientation: SinglePieceOrientation
	typealias Piece = Orientation.Piece
	
	subscript(piece: Piece) -> Orientation { get set }
	
	init()
	init(array: [Orientation])
	
	func asArray() -> [Orientation]
}

extension PieceOrientation {
	func coordinate() -> Coord {
		.init(
			asArray()
				.lazy
				.dropLast() // last is evident from the others
				.map(\.rawValue)
				.reduce(0) { $0 * Orientation.allCases.count + $1 }
		)
	}
	
	init(_ coordinate: Coord) {
		guard coordinate.value != 0 else {
			self = .zero
			return
		}
		
		self.init(
			array: Self.digits(of: coordinate)
				.map { Orientation(rawValue: $0)! }
		)
	}
	
	private static func digits(of coordinate: Coord) -> [Int] {
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
struct CornerOrientation: Hashable, PieceOrientation {
	typealias Tag = SingleCornerOrientation
	typealias Coord = CornerOrientationCoordinate
	
	static let zero = Self()
	
	var urf = SingleCornerOrientation.neutral
	var ufl = SingleCornerOrientation.neutral
	var ulb = SingleCornerOrientation.neutral
	var ubr = SingleCornerOrientation.neutral
	
	var dfr = SingleCornerOrientation.neutral
	var dlf = SingleCornerOrientation.neutral
	var dbl = SingleCornerOrientation.neutral
	var drb = SingleCornerOrientation.neutral
	
	var isFlipped = false
	
	static func + (one: Self, two: Self) -> Self {
		if one.isFlipped {
			return .init(
				urf: one.urf - two.urf,
				ufl: one.ufl - two.ufl,
				ulb: one.ulb - two.ulb,
				ubr: one.ubr - two.ubr,
				
				dfr: one.dfr - two.dfr,
				dlf: one.dlf - two.dlf,
				dbl: one.dbl - two.dbl,
				drb: one.drb - two.drb,
				
				isFlipped: !two.isFlipped
			)
		} else {
			return .init(
				urf: one.urf + two.urf,
				ufl: one.ufl + two.ufl,
				ulb: one.ulb + two.ulb,
				ubr: one.ubr + two.ubr,
				
				dfr: one.dfr + two.dfr,
				dlf: one.dlf + two.dlf,
				dbl: one.dbl + two.dbl,
				drb: one.drb + two.drb,
				
				isFlipped: two.isFlipped
			)
		}
	}
	
	static prefix func - (o: Self) -> Self {
		// TODO: different when flipped?
		.init(
			urf: -o.urf,
			ufl: -o.ufl,
			ulb: -o.ulb,
			ubr: -o.ubr,
			
			dfr: -o.dfr,
			dlf: -o.dlf,
			dbl: -o.dbl,
			drb: -o.drb,
			
			isFlipped: o.isFlipped
		)
	}
	
	func applying(_ perm: CornerPermutation) -> Self {
		// TODO: different when flipped?
		.init(
			urf: self[perm.urf],
			ufl: self[perm.ufl],
			ulb: self[perm.ulb],
			ubr: self[perm.ubr],
			
			dfr: self[perm.dfr],
			dlf: self[perm.dlf],
			dbl: self[perm.dbl],
			drb: self[perm.drb],
			
			isFlipped: isFlipped
		)
	}
	
	static func + (state: Self, transform: CubeTransformation.Corners) -> Self {
		state.applying(transform.permutation) + transform.orientation
	}
	
	static func + (transform: CubeTransformation.Corners, state: Self) -> Self {
		transform.orientation + state
	}
}

extension CornerOrientation: TaggedCorners {
	@_disfavoredOverload
	init(
		urf: SingleCornerOrientation,
		ufl: SingleCornerOrientation,
		ulb: SingleCornerOrientation,
		ubr: SingleCornerOrientation,
		
		dfr: SingleCornerOrientation,
		dlf: SingleCornerOrientation,
		dbl: SingleCornerOrientation,
		drb: SingleCornerOrientation
	) {
		//fatalError("CornerOrientation cannot be initialized from array because it needs to know if it's flipped.")
		self.init(
			urf: urf, ufl: ufl, ulb: ulb, ubr: ubr,
			dfr: dfr, dlf: dlf, dbl: dbl, drb: drb,
			isFlipped: false
		)
	}
}

/// defines for each spot which orientation its corner has relative to U/D
struct EdgeOrientation: Hashable, PieceOrientation, TaggedEdges {
	typealias Tag = SingleEdgeOrientation
	typealias Coord = EdgeOrientationCoordinate
	
	static let zero = Self()
	
	var ur = SingleEdgeOrientation.neutral
	var uf = SingleEdgeOrientation.neutral
	var ul = SingleEdgeOrientation.neutral
	var ub = SingleEdgeOrientation.neutral
	
	var dr = SingleEdgeOrientation.neutral
	var df = SingleEdgeOrientation.neutral
	var dl = SingleEdgeOrientation.neutral
	var db = SingleEdgeOrientation.neutral
	
	var fr = SingleEdgeOrientation.neutral
	var fl = SingleEdgeOrientation.neutral
	var bl = SingleEdgeOrientation.neutral
	var br = SingleEdgeOrientation.neutral
	
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
	
	static func + (state: Self, transform: CubeTransformation.Edges) -> Self {
		state.applying(transform.permutation) + transform.orientation
	}
	
	static func + (transform: CubeTransformation.Edges, state: Self) -> Self {
		transform.orientation + state
	}
}
