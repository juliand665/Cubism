import Foundation
import ArrayBuilder

struct Algorithm: Identifiable, Codable {
	let id: ExtensibleID<Self>
	var name: String
	var configuration: CubeConfiguration?
	var variants: [Variant]
	
	struct Variant: Identifiable, Codable {
		let id: ExtensibleID<Self>
		var moves: MoveSequence
	}
}

enum ExtensibleID<Object>: Hashable, Codable {
	case builtIn(String)
	case dynamic(UUID)
}

extension Algorithm {
	static func builtIn(
		id: String,
		name: String,
		configuration: CubeConfiguration? = nil,
		@ArrayBuilder<MoveSequence> variants: () -> [MoveSequence]
	) -> Self {
		.init(
			id: .builtIn(id),
			name: name,
			configuration: configuration,
			variants: variants().map { .init(id: .builtIn(rawID(for: $0)), moves: $0) }
		)
	}
	
	private static func rawID(for sequence: MoveSequence) -> String {
		sequence.map(StandardNotation.description(for:)).joined(separator: " ")
	}
}

struct MoveSequence: Codable {
	var moves: [Move]
}

extension MoveSequence {
	static func randomScramble(length: Int) -> Self {
		let faces = sequence(first: Face.allCases.randomElement()!) { prev in
			Face.allCases.filter { $0 != prev }.randomElement()!
		}
		
		return Self(
			moves: faces.prefix(length).map { Move(
				target: .singleFace($0),
				direction: .allCases.randomElement()!
			) }
		)
	}
}

extension MoveSequence: Collection {
	typealias Element = Move
	typealias Index = Array<Move>.Index
	
	var startIndex: Index { moves.startIndex }
	
	var endIndex: Index { moves.endIndex }
	
	subscript(position: Index) -> Move {
		_read {
			yield moves[position]
		}
	}
	
	func index(after i: Index) -> Index {
		moves.index(after: i)
	}
}

struct AlgorithmCollection {
	var folders: [AlgorithmFolder]
}

struct AlgorithmFolder: Identifiable {
	let id = UUID()
	
	var name: String
	var description: String
	var sections: [Section]
	
	struct Section: Identifiable {
		let id = UUID()
		
		var name: String
		var algorithms: [Algorithm]
	}
}

struct Move: Codable, Hashable, Identifiable {
	let id = UUID()
	var target: Target
	var direction: Direction
	
	private enum CodingKeys: String, CodingKey {
		case target
		case direction
	}
	
	enum Target: Codable, Hashable {
		case singleFace(Face)
		case doubleFace(Face)
		case slice(Slice)
		case rotation(FullCubeRotation)
	}
	
	enum Direction: Codable, CaseIterable {
		case clockwise
		case counterclockwise
		case double
	}
}

enum Face: Character, Codable, CaseIterable {
	case front = "F"
	case back = "B"
	case up = "U"
	case down = "D"
	case left = "L"
	case right = "R"
}

enum Slice: Character, Codable {
	case behindDown = "E"
	case behindLeft = "M"
	case behindFront = "S"
	
	var baseFace: Face {
		switch self {
		case .behindDown:
			return .down
		case .behindLeft:
			return .left
		case .behindFront:
			return .front
		}
	}
}

enum FullCubeRotation: Character, Codable {
	case x = "x"
	case y = "y"
	case z = "z"
}
