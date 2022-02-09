import Foundation

enum PhaseSolver<Coord: PruningCoordinate> where Coord.CubeState == CubeTransformation {
	static func solvePhase1(from start: CubeTransformation) -> [SolverMove]
	where Coord == Phase1Coordinate {
		solve(from: start) { coord, state in coord.intValue == 0 }
	}
	
	static func solvePhase2(from start: CubeTransformation) -> [SolverMove]
	where Coord == Phase2Coordinate {
		solve(from: start) { coord, state in state == .zero }
	}
	
	// TODO: use coords rather than actual transformations
	static func solve(
		from start: CubeTransformation,
		isSolved: (Coord, CubeTransformation) -> Bool
	) -> [SolverMove] {
		func search(
			from start: CubeTransformation, distance: UInt8, bound: UInt8
		) -> SearchResult {
			let startCoord = Coord(start)
			guard !isSolved(startCoord, start) else { return .found(moves: []) }
			
			let heuristic = distance + startCoord.pruningValue
			guard heuristic <= bound else { return .notFound(bestHeuristic: heuristic) }
			
			var bestHeuristic = UInt8.max
			for move in SolverMove.all {
				let neighbor = start + move.transform
				switch search(from: neighbor, distance: distance + 1, bound: bound) {
				case .found(let moves):
					return .found(moves: [move] + moves)
				case .notFound(let heuristic):
					bestHeuristic = min(bestHeuristic, heuristic)
				}
			}
			return .notFound(bestHeuristic: bestHeuristic)
		}
		
		var bound = Coord(start).pruningValue
		while true {
			print("searching up to \(bound)")
			switch search(from: start, distance: 0, bound: bound) {
			case .found(let moves):
				return moves
			case .notFound(let bestHeuristic):
				guard bestHeuristic != bound else { fatalError("search not converging!") }
				bound = bestHeuristic
				print("continuing search up to", bound)
			}
		}
	}
	
	enum SearchResult {
		case found(moves: [SolverMove])
		case notFound(bestHeuristic: UInt8)
	}
}
