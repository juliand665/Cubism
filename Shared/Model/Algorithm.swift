import Foundation
import ArrayBuilder

struct Algorithm: Identifiable, Codable {
	let id: ExtensibleID<Self>
	var name: String
	var description: String
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
		description: String = "",
		configuration: CubeConfiguration? = nil,
		@ArrayBuilder<MoveSequence> variants: () -> [MoveSequence]
	) -> Self {
		.init(
			id: .builtIn(id),
			name: name,
			description: description,
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
	init(_ maneuver: SolverManeuver) {
		self.init(moves: maneuver.moves.map(\.action.move))
	}
}

enum ScrambleGenerator {
	#if DEBUG
	static func mockInitializeForPreviews() {
		isPrepared = true
	}
	#endif
	
	static private(set) var isPrepared = false
	
	static func prepare() async {
		let basicState: CubeTransformation = .rightTurn + .frontTurn
		await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
			DispatchQueue.global(qos: .userInitiated).async {
				BasicTwoPhaseSolver(start: basicState).searchNextLevel()
				continuation.resume()
			}
		}
		isPrepared = true
	}
	
	static func generate() -> MoveSequence {
		let solver = ThreeWayTwoPhaseSolver(start: .random())
		solver.searchNextLevel()
		return .init(moves: solver.bestSolution!.moves.map(\.action.move))
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
		case wideTurn(Face, sliceCount: Int)
		case slice(Slice)
		case bigSlice(Face, sliceNumber: Int)
		case rotation(FullCubeRotation)
	}
	
	enum Direction: Codable, CaseIterable {
		static let inCWOrder = [clockwise, double, counterclockwise]
		
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
