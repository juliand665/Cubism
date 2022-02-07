import Foundation

enum PhaseSolver<Coord: PruningCoordinate> where Coord.CubeState == CubeTransformation {
	static func solvePhase1(from start: CubeTransformation) -> [SolverMove] where Coord == Phase1Coordinate {
		solve(from: start)
	}
	
	static func solve(from start: CubeTransformation) -> [SolverMove] {
		var bound = Coord(start).pruningValue
		while true {
			print("searching up to \(bound)")
			switch search(from: start, distance: 0, bound: bound) {
			case .found(let moves):
				return moves
			case .notFound(let bestHeuristic):
				bound = bestHeuristic
				print("continuing search up to", bound)
			}
		}
	}
	
	private static func search(from start: CubeTransformation, distance: UInt8, bound: UInt8) -> SearchResult {
		let startCoord = Coord(start)
		guard startCoord.intValue != 0 else { return .found(moves: []) }
		
		let heuristic = distance + startCoord.pruningValue
		guard heuristic <= bound else { return .notFound(bestHeuristic: heuristic) }
		
		print("searching from", startCoord)
		
		var bestHeuristic = heuristic
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
	
	enum SearchResult {
		case found(moves: [SolverMove])
		case notFound(bestHeuristic: UInt8)
	}
}
