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

extension CubeTransformation {
	func solve(alternativesConsidered: Int = 100) -> [SolverMove] {
		measureTime(as: "solving with \(alternativesConsidered) alternatives") {
			let start = Phase1Coordinate(self)
			
			var considered = 0
			var bestSolution: [SolverMove]?
			for phase1Length in start.minDistance... {
				if let bestSolution = bestSolution {
					guard phase1Length < bestSolution.count else { break }
				}
				
				let alternatives = PhaseSolver.solutions(from: start, exactLength: phase1Length)
				print("considering \(alternatives.count) phase 1 solutions of length \(phase1Length)")
				for phase1Moves in alternatives {
					// can't just use a coordinate here because it's not valid to perform non-phase2 moves on phase2 coordinates
					let state = phase1Moves.map(\.transform).reduce(self, +)
					let phase2Start = FullPhase2Coordinate(state)
					guard !phase2Start.isZero else { return phase1Moves } // already solved with minimal length
					
					let phase2Solutions = PhaseSolver.solutions(
						from: phase2Start,
						maxLength: bestSolution.map { .init($0.count - phase1Moves.count) }
					)
					guard let phase2Moves = phase2Solutions.first else { continue }
					
					let length = phase1Moves.count + phase2Moves.count
					let bestLength = bestSolution?.count ?? .max
					guard length < bestLength else { continue }
					
					bestSolution = phase1Moves + phase2Moves
					print("found solution with \(length) moves")
				}
				
				considered += alternatives.count
				guard considered <= alternativesConsidered else { break }
			}
			return bestSolution!
		}
	}
}

enum PhaseSolver<Coord: SolverCoordinate> {
	static func solutions(from start: Coord, exactLength: UInt8) -> [[SolverMove]] {
		switch search(from: start, distance: 0, maxDistance: exactLength, allowShorter: false) {
		case .found(let paths):
			return paths
		case .notFound:
			return []
		}
	}
	
	static func solutions(from start: Coord, maxLength: UInt8? = nil) -> [[SolverMove]] {
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
			return .found(paths: [[]])
		}
		
		let heuristic = distance + start.minDistance
		guard heuristic <= maxDistance else { return .notFound(bestHeuristic: heuristic) }
		
		var bestHeuristic = UInt8.max
		var foundPaths: [[SolverMove]] = []
		for move in Coord.allowedMoves {
			switch search(
				from: start + move,
				distance: distance + 1,
				maxDistance: maxDistance,
				allowShorter: allowShorter
			) {
			case .found(let paths):
				foundPaths += paths.lazy.map { [move] + $0 }
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
		case found(paths: [[SolverMove]])
		case notFound(bestHeuristic: UInt8)
	}
}
