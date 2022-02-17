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

// TODO: consider all 3 axes for defining edge orientation (i.e. just the urf3 symmetry group)
extension CubeTransformation {
	func solve(alternativesConsidered: Int = 1000) -> SolverManeuver {
		measureTime(as: "solving with \(alternativesConsidered) alternatives") {
			let start = Phase1Coordinate(self)
			
			var considered = 0
			var bestSolution: SolverManeuver?
			for phase1Length in start.minDistance... {
				if let bestSolution = bestSolution {
					guard phase1Length < bestSolution.length else { break }
				}
				
				let alternatives = measureTime(as: "computing phase 1 solutions of length \(phase1Length)") {
					PhaseSolver.solutions(from: start, exactLength: phase1Length)
				}
				let earlySolution = measureTime(as: "trying out \(alternatives.count) alternatives") { () -> SolverManeuver? in
					for phase1 in alternatives {
						// can't just use a coordinate here because it's not valid to perform non-phase2 moves on phase2 coordinates
						let state = phase1.applied(to: self)
						let phase2Start = FullPhase2Coordinate(state)
						guard !phase2Start.isZero else { return phase1 } // already solved with minimal length
						
						let phase2Solutions = PhaseSolver.solutions(
							from: phase2Start,
							maxLength: bestSolution.map { .init($0.length - phase1.length) }
						)
						guard let phase2 = phase2Solutions.first else { continue }
						
						let length = phase1.length + phase2.length
						let bestLength = bestSolution?.length ?? .max
						guard length < bestLength else { continue }
						
						bestSolution = phase1 + phase2
						print("found solution with \(length) moves")
					}
					return nil
				}
				if let earlySolution = earlySolution { return earlySolution }
				
				considered += alternatives.count
				guard considered <= alternativesConsidered else { break }
			}
			return bestSolution!
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
	
	func prepending(_ move: SolverMove) -> Self {
		.init(moves: [move] + moves)
	}
	
	static func + (lhs: Self, rhs: Self) -> Self {
		.init(moves: lhs.moves + rhs.moves)
	}
}
