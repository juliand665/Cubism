import Foundation

enum CubeConfiguration: Codable {
	case oll(OLLConfiguration)
	case pll(PLLPermutation)
}

struct OLLConfiguration: Codable {
	var correctEdges = FaceEdge.Set.all
	
	var neCorner: CornerState?
	var seCorner: CornerState?
	var swCorner: CornerState?
	var nwCorner: CornerState?
	
	static func edgesOnly(correctEdges: FaceEdge.Set) -> Self {
		.init(correctEdges: correctEdges)
	}
	
	static func cornersOnly(
		ne: CornerState = .correct,
		se: CornerState = .correct,
		sw: CornerState = .correct,
		nw: CornerState = .correct
	) -> Self {
		.init(neCorner: ne, seCorner: se, swCorner: sw, nwCorner: nw)
	}
	
	enum CornerState: Codable {
		case correct
		/// e.g. when the NE corner is facing east
		case facingCW
		/// e.g. when the NE corner is facing north
		case facingCCW
	}
}

struct PLLPermutation: Codable {
	var edgeCycles: [[FaceEdge]] = []
	var cornerCycles: [[FaceCorner]] = []
}

enum FaceEdge: Int, Codable {
	case north
	case east
	case south
	case west
	
	struct Set: OptionSet, Codable {
		static let north = Self(.north)
		static let east = Self(.east)
		static let south = Self(.south)
		static let west = Self(.west)
		
		static let all: Self = [.north, .east, .south, .west]
		
		var rawValue: UInt8
	}
}

extension FaceEdge.Set {
	init(_ edge: FaceEdge) {
		self.init(rawValue: 1 << edge.rawValue)
	}
}

enum FaceCorner: Int, Codable {
	case northEast
	case southEast
	case southWest
	case northWest
	
	static let ne = northEast
	static let se = southEast
	static let sw = southWest
	static let nw = northWest
	
	struct Set: OptionSet, Codable {
		static let ne = northEast
		static let northEast = Self(rawValue: 1 << 0)
		static let se = southEast
		static let southEast = Self(rawValue: 1 << 1)
		static let sw = southWest
		static let southWest = Self(rawValue: 1 << 2)
		static let nw = northWest
		static let northWest = Self(rawValue: 1 << 3)
		
		static let all: Self = [.ne, .se, .sw, .nw]
		
		var rawValue: UInt8
	}
}
