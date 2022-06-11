import Foundation
import HandyOperators

enum CubeConfiguration: Codable {
	case oll(OLLConfiguration)
	case pll(PLLPermutation)
	
	var checkable: CheckableConfiguration {
		switch self {
		case .oll(let oll):
			return oll
		case .pll(let pll):
			return pll
		}
	}
}

protocol CheckableConfiguration {
	init(_ state: CubeTransformation) throws
	func matches(_ state: CubeTransformation) throws -> Bool
}

struct OLLConfiguration: Codable {
	var correctEdges = FaceEdge.Set.all
	
	var neCorner: SingleCornerOrientation?
	var seCorner: SingleCornerOrientation?
	var swCorner: SingleCornerOrientation?
	var nwCorner: SingleCornerOrientation?
	
	static func edgesOnly(correctEdges: FaceEdge.Set) -> Self {
		.init(correctEdges: correctEdges)
	}
	
	static func cornersOnly(
		ne: SingleCornerOrientation = .neutral,
		se: SingleCornerOrientation = .neutral,
		sw: SingleCornerOrientation = .neutral,
		nw: SingleCornerOrientation = .neutral
	) -> Self {
		.init(neCorner: ne, seCorner: se, swCorner: sw, nwCorner: nw)
	}
}

extension OLLConfiguration: CheckableConfiguration {
	init(_ transform: CubeTransformation) {
		assert(transform.affectsOnlyULayer())
		
		let state = -transform // OLLs are defined in terms of the previous state
		let edges = state.edges.orientation
		correctEdges = .init(FaceEdge.allCases
			.filter { edges[$0.uPiece] == .neutral }
			.map(FaceEdge.Set.init(_:))
		)
		
		let corners = state.corners.orientation
		neCorner = corners.ubr
		seCorner = corners.urf
		swCorner = corners.ufl
		nwCorner = corners.ulb
	}
	
	func matches(_ state: CubeTransformation) -> Bool {
		let other = Self(state)
		return correctEdges == other.correctEdges
		&& (neCorner.map { $0 == other.neCorner } ?? true)
		&& (seCorner.map { $0 == other.seCorner } ?? true)
		&& (swCorner.map { $0 == other.swCorner } ?? true)
		&& (nwCorner.map { $0 == other.nwCorner } ?? true)
	}
}

struct PLLPermutation: Codable {
	var edgeCycles: [[FaceEdge]] = []
	var cornerCycles: [[FaceCorner]] = []
}

extension PLLPermutation: CheckableConfiguration {
	init(_ transform: CubeTransformation) throws {
		assert(transform.affectsOnlyULayer())
		
		// PLLs are defined in terms of how they move pieces
		edgeCycles = try transform.edges.permutation.cycles().map {
			try $0.map {
				try FaceEdge(uPiece: $0)
				??? TransformationConversionError.pieceOutsideULayerAffected($0)
			}
		}
		
		cornerCycles = transform.corners.permutation.cycles().map {
			$0.map(FaceCorner.init(uPiece:))
		}
	}
	
	func matches(_ state: CubeTransformation) throws -> Bool {
		let other = try Self(state)
		return cyclesMatch(edgeCycles, other.edgeCycles)
		&& cyclesMatch(cornerCycles, other.cornerCycles)
	}
	
	enum TransformationConversionError: Error {
		case pieceOutsideULayerAffected(Edge)
	}
}

private func cyclesMatch<T: Equatable>(_ lhs: [[T]], _ rhs: [[T]]) -> Bool {
	guard lhs.count == rhs.count else { return false }
	for cycle in lhs {
		let start = cycle.first!
		guard let other = rhs.first(where: { $0.contains(start) }) else { return false }
		let aligned = other.drop { $0 != start } + other
		guard aligned.starts(with: cycle) else { return false }
	}
	return true
}

extension CubeTransformation {
	func affectsOnlyULayer() -> Bool {
		true
		&& edges.orientation.dropFirst(4).allSatisfy { $0 == .neutral }
		&& edges.permutation.dropFirst(4).elementsEqual(Edge.allCases.dropFirst(4))
		&& corners.orientation.dropFirst(4).allSatisfy { $0 == .neutral }
		&& corners.permutation.dropFirst(4).elementsEqual(Corner.allCases.dropFirst(4))
	}
}

enum FaceEdge: Int, Codable, CaseIterable {
	case north
	case east
	case south
	case west
	
	var uPiece: Edge {
		switch self {
		case .north:
			return .ub
		case .east:
			return .ur
		case .south:
			return .uf
		case .west:
			return .ul
		}
	}
	
	init?(uPiece: Edge) {
		switch uPiece {
		case .ub:
			self = .north
		case .ur:
			self = .east
		case .uf:
			self = .south
		case .ul:
			self = .west
		default:
			return nil
		}
	}
	
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

enum FaceCorner: Int, Codable, CaseIterable {
	case northEast
	case southEast
	case southWest
	case northWest
	
	static let ne = northEast
	static let se = southEast
	static let sw = southWest
	static let nw = northWest
	
	var uPiece: Corner {
		switch self {
		case .northEast:
			return .ubr
		case .southEast:
			return .urf
		case .southWest:
			return .ufl
		case .northWest:
			return .ulb
		}
	}
	
	init(uPiece: Corner) {
		switch uPiece {
		case .ubr:
			self = .northEast
		case .urf:
			self = .southEast
		case .ufl:
			self = .southWest
		case .ulb:
			self = .northWest
		case let other:
			fatalError("piece \(other) not in U layer")
		}
	}
	
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
