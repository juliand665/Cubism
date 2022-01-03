protocol TaggedPieces {
	associatedtype Tag
	associatedtype Piece
	
	subscript(piece: Piece) -> Tag { get set }
	
	init(array: [Tag])
	func asArray() -> [Tag]
}

protocol TaggedCorners: TaggedPieces where Piece == Corner {
	var urf: Tag { get set }
	var ufl: Tag { get set }
	var ulb: Tag { get set }
	var ubr: Tag { get set }
	
	var dfr: Tag { get set }
	var dlf: Tag { get set }
	var dbl: Tag { get set }
	var drb: Tag { get set }
	
	init(
		urf: Tag,
		ufl: Tag,
		ulb: Tag,
		ubr: Tag,
		
		dfr: Tag,
		dlf: Tag,
		dbl: Tag,
		drb: Tag
	)
}

extension TaggedCorners {
	init(array: [Tag]) {
		precondition(array.count == Piece.allCases.count)
		self.init(
			urf: array[0],
			ufl: array[1],
			ulb: array[2],
			ubr: array[3],
			
			dfr: array[4],
			dlf: array[5],
			dbl: array[6],
			drb: array[7]
		)
	}
	
	func asArray() -> [Tag] {
		[urf, ufl, ulb, ubr, dfr, dlf, dbl, drb]
	}
	
	subscript(corner: Corner) -> Tag {
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
}

protocol TaggedEdges: TaggedPieces where Piece == Edge {
	var ur: Tag { get set }
	var uf: Tag { get set }
	var ul: Tag { get set }
	var ub: Tag { get set }
	
	var dr: Tag { get set }
	var df: Tag { get set }
	var dl: Tag { get set }
	var db: Tag { get set }
	
	var fr: Tag { get set }
	var fl: Tag { get set }
	var bl: Tag { get set }
	var br: Tag { get set }
	
	init(
		ur: Tag,
		uf: Tag,
		ul: Tag,
		ub: Tag,
		
		dr: Tag,
		df: Tag,
		dl: Tag,
		db: Tag,
		
		fr: Tag,
		fl: Tag,
		bl: Tag,
		br: Tag
	)
}

extension TaggedEdges {
	init(array: [Tag]) {
		precondition(array.count == Piece.allCases.count)
		self.init(
			ur: array[0],
			uf: array[1],
			ul: array[2],
			ub: array[3],
			
			dr: array[4],
			df: array[5],
			dl: array[6],
			db: array[7],
			
			fr: array[8],
			fl: array[9],
			bl: array[10],
			br: array[11]
		)
	}
	
	func asArray() -> [Tag] {
		[ur, uf, ul, ub, dr, df, dl, db, fr, fl, bl, br]
	}
	
	subscript(edge: Edge) -> Tag {
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
}
