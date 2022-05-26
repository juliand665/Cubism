protocol TaggedPieces: RandomAccessCollection where Index == Int {
	associatedtype Tag where Tag == Element
	// would like to declare it like this instead but that breaks the compiler…
	//typealias Tag = Element
	
	associatedtype Piece: CubePiece
	
	subscript(piece: Piece) -> Tag { get set }
	
	init(array: [Tag])
}

protocol TaggedCorners: TaggedPieces, PartialCornerState where Piece == Corner {
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

protocol TaggedEdges: TaggedPieces, PartialEdgeState where Piece == Edge {
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

extension Collection where Self: TaggedPieces {
	var startIndex: Int { 0 }
	
	func index(after i: Int) -> Int {
		i + 1
	}
}

extension Collection where Self: TaggedCorners {
	var endIndex: Int { 8 }
	
	subscript(position: Int) -> Tag {
		switch position { // gotta go fast
		case 00: return urf
		case 01: return ufl
		case 02: return ulb
		case 03: return ubr
			
		case 04: return dfr
		case 05: return dlf
		case 06: return dbl
		case 07: return drb
			
		default: fatalError()
		}
	}
}

extension Collection where Self: TaggedEdges {
	var endIndex: Int { 12 }
	
	subscript(position: Int) -> Tag {
		switch position { // gotta go fast
		case 00: return ur
		case 01: return uf
		case 02: return ul
		case 03: return ub
			
		case 04: return dr
		case 05: return df
		case 06: return dl
		case 07: return db
			
		case 08: return fr
		case 09: return fl
		case 10: return bl
		case 11: return br
			
		default: fatalError()
		}
	}
}
