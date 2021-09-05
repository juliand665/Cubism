import Foundation

enum CubeConfiguration: Codable {
	case oll(OLLConfiguration)
	case pll(PLLPermutation)
}

struct OLLConfiguration: Codable {
	var correctEdges: FaceEdge = .all
	
	var neCorner: CornerState?
	var seCorner: CornerState?
	var swCorner: CornerState?
	var nwCorner: CornerState?
	
	static func edgesOnly(correctEdges: FaceEdge) -> Self {
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

struct FaceEdge: OptionSet, Codable {
	static let north = Self(rawValue: 1 << 0)
	static let east = Self(rawValue: 1 << 1)
	static let south = Self(rawValue: 1 << 2)
	static let west = Self(rawValue: 1 << 3)
	
	static let all: Self = [.north, .east, .south, .west]
	
	var rawValue: UInt8
}

struct FaceCorner: OptionSet, Codable {
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
