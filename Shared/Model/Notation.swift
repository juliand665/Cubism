import Foundation

protocol Notation {
	static func description(for move: Move) -> String
}

enum StandardNotation: Notation {
	static func description(for move: Move) -> String {
		let target = description(for: move.target)
		switch move.direction {
		case .clockwise:
			return target
		case .counterclockwise:
			return "\(target)'"
		case .double:
			return "\(target)2"
		}
	}
	
	static func description(for target: Move.Target) -> String {
		switch target {
		case .singleFace(let face):
			return face.rawValue.uppercased()
		case .doubleFace(let face):
			return face.rawValue.lowercased()
		case .wideTurn(let face, let sliceCount):
			return "\(sliceCount == 2 ? "" : "\(sliceCount)")\(face.rawValue)w"
		case .slice(let slice):
			return slice.rawValue.uppercased()
		case .bigSlice(let face, let sliceNumber):
			return "\(sliceNumber)\(face.rawValue)"
		case .rotation(let rotation):
			return rotation.rawValue.lowercased()
		}
	}
}

enum NaturalNotation: Notation {
	static func description(for move: Move) -> String {
		let target = StandardNotation.description(for: move.target)
		switch move.direction {
		case .clockwise:
			return target
		case .counterclockwise:
			return "\(target)i"
		case .double:
			return "\(target)\(target.suffix(1))"
		}
	}
}
