import Foundation

protocol PruningCoordinate: ComposedCoordinate, CoordinateWithMoves
where OuterCoord: ReducedCoordinate, InnerCoord: CoordinateWithSymmetries {}

struct PruningTable<Coord: PruningCoordinate> {
	var distances: [UInt8]
	
	init() {
		distances = .init(repeating: .max, count: Coord.count)
		
		print(Coord.OuterCoord.allValues.count(where: \.representant.hasSymmetries))
		print(Coord.OuterCoord.allValues.count)
		print(Coord.allValues.count(where: \.outerCoord.representant.hasSymmetries))
		print(Coord.allValues.count)
		
		print("setting up pruning table")
		distances[0] = 0
		var distance: UInt8 = 1
		var statesReached = 1
		while statesReached < distances.count {
			measureTime(as: "search at distance \(distance)") {
				let statesReachedBefore = statesReached
				defer {
					print("\(statesReached - statesReachedBefore) new states reached")
				}
				
				let isSearchingForwards = statesReached < distances.count / 4
				print(isSearchingForwards ? "searching forwards" : "searching backwards")
				let distanceToSearch = isSearchingForwards ? distance - 1 : .max
				
				for index in distances.indices {
					guard distances[index] == distanceToSearch else { continue }
					// takes 162 ns per entry (80 ns on my iPhone 11 Pro Max)
					
					let coord = Coord(index)
					let neighbors = SolverMove.all.lazy.map { coord + $0 }
					if isSearchingForwards {
						for neighbor in neighbors {
							let index = neighbor.intValue
							guard distances[index] == .max else { continue }
							
							distances[index] = distance
							statesReached += 1
							
							let representant = neighbor.outerCoord.representant
							if representant.hasSymmetries { // applies to ~3% of values
								for symmetry in StandardSymmetry.all.dropFirst() where representant.hasSymmetry(symmetry) {
									let shiftedInner = neighbor.innerCoord.shifted(with: symmetry)
									let new = Coord(neighbor.outerCoord, shiftedInner)
									guard distances[new.intValue] == .max else { continue }
									distances[new.intValue] = distance
									statesReached += 1
								}
							}
						}
					} else {
						let isReachable = neighbors.contains { distances[$0.intValue] == distance - 1 }
						guard isReachable else { continue }
						distances[index] = distance
						statesReached += 1
					}
				}
				
				distance += 1
			}
		}
	}
}
