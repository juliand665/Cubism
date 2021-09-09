import Foundation

extension MoveSequence {
	init(parsing raw: String) throws {
		self.init(moves: try NotationParser.moves(in: raw))
	}
}

extension MoveSequence: ExpressibleByStringLiteral {
	init(stringLiteral raw: String) {
		try! self.init(parsing: raw)
	}
}

enum NotationParser {
	private static let semanticCharacters = Set("()[]{}_")
	
	static func moves(in raw: String) throws -> [Move] {
		let rawMoves = raw
			.filter { !semanticCharacters.contains($0) }
			.components(separatedBy: .whitespaces)
		
		return try rawMoves.compactMap { raw in
			guard let rawTarget = raw.first else { return nil }
			let target = try target(for: rawTarget)
			
			let direction: Move.Direction
			switch raw.dropFirst() {
			case "":
				direction = .clockwise
			case "'", "i":
				direction = .counterclockwise
			case "2", String(rawTarget):
				direction = .double
			case let other:
				throw ParseError.unknownDirection(String(other))
			}
			
			return .init(target: target, direction: direction)
		}
	}
	
	static func target(for raw: Character) throws -> Move.Target {
		if let face = Face(rawValue: raw) {
			return .singleFace(face)
		} else if let uppercased = raw.uppercased().first, let face = Face(rawValue: uppercased) {
			return .doubleFace(face)
		} else if let slice = Slice(rawValue: raw) {
			return .slice(slice)
		} else if let rotation = FullCubeRotation(rawValue: raw) {
			return .rotation(rotation)
		} else {
			throw ParseError.unknownTarget(raw)
		}
	}
	
	enum ParseError: Error {
		case unknownTarget(Character)
		case unknownDirection(String)
	}
}
