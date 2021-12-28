import Foundation
import SimpleParser

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
			guard !raw.isEmpty else { return nil }
			var parser = Parser(reading: raw)
			let target = try target(from: &parser)
			
			let direction: Move.Direction
			switch parser.consumeRest() {
			case "":
				direction = .clockwise
			case "'", "i":
				direction = .counterclockwise
			case "2", StandardNotation.description(for: target).suffix(1):
				direction = .double
			case let other:
				throw ParseError.unknownDirection(String(other))
			}
			
			return .init(target: target, direction: direction)
		}
	}
	
	static func target(from parser: inout Parser) throws -> Move.Target {
		if parser.next!.isNumber {
			// wide turn with explicit slice count
			let sliceCount = parser.readInt()
			let raw = parser.consumeNext()
			guard let face = Face(rawValue: raw) else {
				throw ParseError.unknownTarget(raw)
			}
			if parser.next == "w" {
				parser.consumeNext()
				return .wideTurn(face, sliceCount: sliceCount)
			} else {
				return .bigSlice(face, sliceNumber: sliceCount)
			}
		}
		let raw = parser.consumeNext()
		if let face = Face(rawValue: raw) {
			if parser.next == "w" {
				parser.consumeNext()
				return .wideTurn(face, sliceCount: 2)
			} else {
				return .singleFace(face)
			}
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
