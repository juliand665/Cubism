import Foundation
import Algorithms

protocol SolverCoordinate: CoordinateWithMoves {
	static var allowedMoves: [SolverMove] { get }
	
	/// a lower bound on how far this value is from the solved (zero) state
	var minDistance: UInt8 { get }
}

extension SolverCoordinate where Self: PruningCoordinate {
	var minDistance: UInt8 { pruningValue }
}

protocol Solver {
	var bestSolution: SolverManeuver? { get }
	var isDone: Bool { get }
	
	func searchNextLevel()
}

/// Applies `BasicTwoPhaseSolver` along all three axes, yielding more consistent results regardless of cube rotation.
final class ThreeWayTwoPhaseSolver: Solver {
	let solvers: [(symmetry: Symmetry, solver: BasicTwoPhaseSolver)]
	
	var nextPhase1Length: UInt8
	var bestSolution: SolverManeuver?
	var isDone = false
	
	init(start: CubeTransformation) {
		self.solvers = Symmetry.urf3Subgroup.map { symmetry in
			(symmetry, .init(start: symmetry.shift(start)))
		}
		self.nextPhase1Length = solvers.map(\.solver.nextPhase1Length).min()!
	}
	
	func searchNextLevel() {
		// TODO: benchmark just how little i can get away with here if i'm using symmetries
		for (symmetry, solver) in solvers {
			guard solver.nextPhase1Length == nextPhase1Length else { continue }
			solver.searchNextLevel()
			
			guard
				let newSolution = solver.bestSolution,
				newSolution.length < bestSolution?.length ?? .max
			else { continue }
			bestSolution = newSolution.shifted(with: symmetry.inverse)
		}
		
		nextPhase1Length += 1
		if let bestSolution = bestSolution {
			isDone = nextPhase1Length >= bestSolution.length
		}
	}
}

final class BasicTwoPhaseSolver: Solver {
	let start: CubeTransformation
	let phase1Start: Phase1Coordinate
	let startEdgePerm: SubsettedEdgePermutationCoordinate
	let startCornerPerm: ReducedCornerPermutationCoordinate
	
	var nextPhase1Length: UInt8
	var bestSolution: SolverManeuver?
	var isDone = false
	
	init(start: CubeTransformation) {
		self.start = start
		self.phase1Start = .init(start)
		self.startEdgePerm = .init(start.edges.permutation)
		self.startCornerPerm = .init(start.corners.permutation)
		
		self.nextPhase1Length = phase1Start.minDistance
	}
	
	func searchNextLevel() {
		guard !isDone else { return }
		
		let alternatives = PhaseSolver.solutions(from: phase1Start, exactLength: nextPhase1Length)
		print(alternatives.count, terminator: ", ")
		fflush(stdout)
		
		for phase1 in alternatives {
			// can't just use a coordinate here because it's not valid to perform non-phase2 moves on phase2 coordinates
			// TODO: implement other coords like udSlice from which this can be restored
			// TODO: generate a small pruning table for corner permutation (and maybe the others too?) to quickly discard phase 1 solutions which can't improve our solution
			// TODO: create phase 2 coords directly from their respective subset coords
			//let state = phase1.applied(to: start)
			let edgePerm = phase1.applied(to: startEdgePerm)
			let edgePermState = edgePerm.makeState()
			//let slice = SliceEdgePermutationCoordinate(edgePermState)
			//let gtSlice = SliceEdgePermutationCoordinate(state.edges.permutation)
			//assert(slice == gtSlice)
			
			let corners = phase1.applied(to: startCornerPerm)
			//let gtCorners = ReducedCornerPermutationCoordinate(state.corners.permutation)
			let phase2Start = FullPhase2Coordinate(
				base: .init(
					reduced: corners,
					edges: .init(edgePermState)
				),
				slice: .init(edgePermState)
			)
			//let gtPhase2Start = FullPhase2Coordinate(state)
			//assert(phase2Start.makeState() == gtPhase2Start.makeState())
			
			guard !phase2Start.isZero else {
				// already solved with minimal length
				bestSolution = phase1
				break
			}
			
			let phase2Solutions = PhaseSolver.solutions(
				from: phase2Start,
				maxLength: bestSolution.map { .init($0.length - phase1.length) }
			)
			guard let phase2 = phase2Solutions.first else { continue }
			
			let length = phase1.length + phase2.length
			let bestLength = bestSolution?.length ?? .max
			guard length < bestLength else { continue }
			
			bestSolution = phase1 + phase2
			//print("found solution with \(length) moves")
		}
		
		nextPhase1Length += 1
		if let bestSolution = bestSolution {
			isDone = nextPhase1Length >= bestSolution.length
		}
	}
}

enum PhaseSolver<Coord: SolverCoordinate> {
	static func solutions(from start: Coord, exactLength: UInt8) -> [SolverManeuver] {
		switch search(from: start, distance: 0, maxDistance: exactLength, allowShorter: false) {
		case .found(let paths):
			return paths
		case .notFound:
			return []
		}
	}
	
	static func solutions(from start: Coord, maxLength: UInt8? = nil) -> [SolverManeuver] {
		var bound = min(start.minDistance, maxLength ?? .max)
		while true {
			if let maxLength = maxLength {
				guard bound <= maxLength else { return [] }
			}
			
			switch search(from: start, distance: 0, maxDistance: bound) {
			case .found(let paths):
				return paths
			case .notFound(let bestHeuristic):
				guard bestHeuristic > bound else { fatalError("search not converging!") }
				bound = bestHeuristic
			}
		}
	}
	
	private static func search(
		from start: Coord, distance: UInt8,
		maxDistance: UInt8,
		allowShorter: Bool = true
	) -> SearchResult {
		guard !start.isZero else {
			if !allowShorter {
				guard distance == maxDistance else { return .notFound(bestHeuristic: 0) }
			}
			return .found(paths: [.empty])
		}
		
		let heuristic = distance + start.minDistance
		guard heuristic <= maxDistance else { return .notFound(bestHeuristic: heuristic) }
		
		var bestHeuristic = UInt8.max
		var foundPaths: [SolverManeuver] = []
		for move in Coord.allowedMoves {
			switch search(
				from: start + move,
				distance: distance + 1,
				maxDistance: maxDistance,
				allowShorter: allowShorter
			) {
			case .found(let paths):
				foundPaths += paths.lazy.map { $0.prepending(move) }
			case .notFound(let heuristic):
				bestHeuristic = min(bestHeuristic, heuristic)
			}
		}
		
		if !foundPaths.isEmpty {
			return .found(paths: foundPaths)
		} else {
			return .notFound(bestHeuristic: bestHeuristic)
		}
	}
	
	enum SearchResult {
		case found(paths: [SolverManeuver])
		case notFound(bestHeuristic: UInt8)
	}
}

struct SolverManeuver: CustomStringConvertible {
	static var empty = Self(moves: [])
	
	var moves: [SolverMove]
	
	var length: Int { moves.count }
	
	var description: String {
		"SolverManeuver(\(moves.map(\.action).map(String.init).joined(separator: " ")))"
	}
	
	func applied(to state: CubeTransformation) -> CubeTransformation {
		moves.lazy.map(\.transform).reduce(state, +)
	}
	
	func applied<Coord: CoordinateWithMoves>(to coord: Coord) -> Coord {
		moves.reduce(coord, +)
	}
	
	func prepending(_ move: SolverMove) -> Self {
		.init(moves: [move] + moves)
	}
	
	func shifted(with symmetry: Symmetry) -> Self {
		.init(moves: moves.map(symmetry.shift))
	}
	
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(moves: lhs.moves + rhs.moves)
	}
}
