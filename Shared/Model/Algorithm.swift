import Foundation
import ArrayBuilder
import HandyOperators

struct Algorithm: Identifiable, Codable {
	let id: ExtensibleID<Self>
	var name: String
	var description: String
	var configuration: CubeConfiguration?
	var variants: [Variant]
	
	struct Variant: Identifiable, Codable {
		let id: ExtensibleID<Self>
		var moves: MoveSequence
		
		var rotation: Int { moves.rotation }
		
		func rotated(by ordinal: Int) -> Self {
			.init(id: id, moves: moves.rotated(by: ordinal))
		}
		
		func withoutRotation() -> Self {
			rotated(by: -rotation)
		}
	}
}

enum ExtensibleID<Object>: Hashable, Codable {
	case builtIn(String)
	case dynamic(UUID)
}

extension ExtensibleID {
	static func newDynamic() -> Self {
		.dynamic(.init())
	}
}

extension Algorithm {
	static func builtIn(
		id: String,
		name: String,
		description: String = "",
		configuration: BuiltInConfiguration = .none,
		@ArrayBuilder<MoveSequence> variants: () -> [MoveSequence]
	) -> Self {
		let variants = variants()
		let resolved = configuration.resolve(variants: variants)
		resolved?.check(variants)
		return .init(
			id: .builtIn(id),
			name: name,
			description: description,
			configuration: resolved,
			variants: variants.map { .init(id: .builtIn(rawID(for: $0)), moves: $0) }
		)
	}
	
	enum BuiltInConfiguration {
		case none
		case computedOLL
		case computedPLL
		case oll(OLLConfiguration)
		case pll(PLLPermutation)
		
		func resolve(variants: [MoveSequence]) -> CubeConfiguration? {
			switch self {
			case .none:
				return nil
			case .computedOLL:
				return .oll(try! .init(
					variants.first!.transformReversingRotations()
				))
			case .computedPLL:
				return .pll(try! .init(
					variants.first!.transformReversingRotations()
				))
			case .oll(let oll):
				return .oll(oll)
			case .pll(let pll):
				return .pll(pll)
			}
		}
	}
	
	private static func rawID(for sequence: MoveSequence) -> String {
		sequence.map(StandardNotation.description(for:)).joined(separator: " ")
	}
}

extension CubeConfiguration {
	func check(_ variants: [MoveSequence]) {
#if DEBUG
		for variant in variants {
			do {
				try check(variant)
			} catch {
				fatalError("variant \(variant) failed correctness check due to \(error)")
			}
		}
#endif
	}
	
	func check(_ sequence: MoveSequence) throws {
		enum CorrectnessError: Error {
			case configurationMismatch(CubeTransformation)
		}
		
		let transform = try sequence.transformReversingRotations()
		guard try wrappedValue.matches(transform) else {
			throw CorrectnessError.configurationMismatch(transform)
		}
	}
}

struct MoveSequence: Codable, Hashable {
	var moves: [Move]
	
	func rotated(by ordinal: Int) -> Self {
		.init(moves: moves <- { moves in
			var rotation = ordinal + self.rotation
			if moves.first?.target == .rotation(.y) {
				moves.removeFirst()
			}
			rotation = (rotation % 4 + 4) % 4
			if let direction = Move.Direction(ordinal: rotation) {
				moves.insert(.init(target: .rotation(.y), direction: direction), at: 0)
			}
		})
	}
	
	var rotation: Int {
		guard
			let first = moves.first,
			first.target == .rotation(.y)
		else { return 0 }
		return first.direction.ordinal
	}
}

extension MoveSequence {
	init(_ maneuver: SolverManeuver) {
		self.init(moves: maneuver.moves.map(\.action.move))
	}
}

extension MoveSequence: CustomStringConvertible {
	var description: String {
		moves.map(StandardNotation.description(for:)).joined(separator: " ")
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
	
	var allAlgorithms: some Collection<Algorithm> {
		sections.lazy.flatMap(\.algorithms)
	}
	
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
		case double
		case counterclockwise
		
		init?(ordinal: Int) {
			guard Self.inCWOrder.indices.contains(ordinal - 1) else { return nil }
			self = Self.inCWOrder[ordinal - 1]
		}
		
		var ordinal: Int {
			switch self {
			case .clockwise:
				return 1
			case .double:
				return 2
			case .counterclockwise:
				return 3
			}
		}
		
		static prefix func - (direction: Self) -> Self {
			switch direction {
			case .clockwise:
				return .counterclockwise
			case .double:
				return .double
			case .counterclockwise:
				return .clockwise
			}
		}
	}
}

enum Face: Character, Codable, CaseIterable {
	case front = "F"
	case back = "B"
	case up = "U"
	case down = "D"
	case right = "R"
	case left = "L"
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
