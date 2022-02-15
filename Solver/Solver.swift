import Foundation

extension CubeTransformation {
	func solve() -> [SolverMove] {
		let phase1Moves = measureTime(as: "phase 1") {
			PhaseSolver.solvePhase1(from: self)
		}
		print("phase 1 solved:", phase1Moves.map(\.action))
		
		let phase1Result = phase1Moves.map(\.transform).reduce(self, +)
		print(phase1Result)
		
		let phase2Moves = measureTime(as: "phase 2") {
			PhaseSolver.solvePhase2(from: phase1Result)
		}
		print("phase 2 solved:", phase2Moves.map(\.action))
		
		let phase2Result = phase2Moves.map(\.transform).reduce(phase1Result, +)
		print(phase2Result)
		
		return phase1Moves + phase2Moves
	}
}

enum PhaseSolver<Coord: PruningCoordinate> {
	typealias FullCoord = Coord.FullCoordinate
	
	static func solvePhase1(from start: CubeTransformation) -> [SolverMove]
	where Coord == Phase1Coordinate {
		solve(from: .init(start))
	}
	
	static func solvePhase2(from start: CubeTransformation) -> [SolverMove]
	where Coord == Phase2Coordinate {
		solve(from: .init(start))
	}
	
	static func solve(from start: FullCoord) -> [SolverMove] {
		func search(
			from start: FullCoord, distance: UInt8, bound: UInt8
		) -> SearchResult {
			guard !start.isZero else { return .found(moves: []) }
			
			let startCoord = Coord(full: start)
			let heuristic = distance + startCoord.pruningValue
			guard heuristic <= bound else { return .notFound(bestHeuristic: heuristic) }
			
			var bestHeuristic = UInt8.max
			for move in Coord.allowedMoves {
				switch search(from: start + move, distance: distance + 1, bound: bound) {
				case .found(let moves):
					return .found(moves: [move] + moves)
				case .notFound(let heuristic):
					bestHeuristic = min(bestHeuristic, heuristic)
				}
			}
			return .notFound(bestHeuristic: bestHeuristic)
		}
		
		var bound = Coord(full: start).pruningValue
		while true {
			print("searching up to \(bound)")
			switch search(from: start, distance: 0, bound: bound) {
			case .found(let moves):
				return moves
			case .notFound(let bestHeuristic):
				guard bestHeuristic > bound else { fatalError("search not converging!") }
				bound = bestHeuristic
			}
		}
	}
	
	enum SearchResult {
		case found(moves: [SolverMove])
		case notFound(bestHeuristic: UInt8)
	}
}
