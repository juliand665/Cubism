import Foundation

protocol PruningCoordinate: HalfSymmetryCoordinate, CoordinateWithMoves
where OuterCoord: ReducedCoordinate {
	associatedtype FullCoordinate: CoordinateWithMoves
	
	static var allowedMoves: [SolverMove] { get }
	
	static var pruningTable: PruningTable<Self> { get }
	
	init(full: FullCoordinate)
}

extension PruningCoordinate {
	var pruningValue: UInt8 {
		Self.pruningTable[self]
	}
}

typealias PruningTable<Coord: PruningCoordinate> = MoveTable<Coord, UInt8>
// wish this would apply the bounds from the typealias
extension PruningTable where Coord: PruningCoordinate, Entry == UInt8 {
	static func cached() -> CacheBuilder<Entry> {
		cached(create: Self.init)
	}
	
	init() {
		// make sure underlying move/symmetry tables are initialized
		print("initializing underlying tables")
		_ = Coord(0) + SolverMove.all.first!
		
		print("setting up pruning table")
		self.entries = Initializer<Coord>.run()
	}
}

private final class Initializer<Coord: PruningCoordinate> {
	var distances = [UInt8](repeating: .max, count: Coord.count)
	var statesReached: Int32 = 1
	var distance: UInt8 = 1
	var isSearchingForwards = true
	var distanceToSearch: UInt8 = 0
	
	static func run() -> [UInt8] {
		measureTime(as: "\(Self.self)") {
			Initializer().distances
		}
	}
	
	private init() {
		distances[0] = 0
		
		while statesReached < Coord.count {
			measureTime(as: "search at distance \(distance)") {
				let oldReached = statesReached
				defer { print("\(statesReached - oldReached) new states reached") }
				
				let shouldSearchForwards = statesReached < Coord.count / 4
				if isSearchingForwards && !shouldSearchForwards {
					print("flipping backwards!")
				}
				isSearchingForwards = shouldSearchForwards
				distanceToSearch = isSearchingForwards ? distance - 1 : .max
				
				performParallelSearch()
				
				distance += 1
			}
		}
	}
	
	func performParallelSearch() {
		let parallelism = 2 // this is a super memory-heavy workload, so 2 already gives us the maximum benefit
		DispatchQueue.concurrentPerform(iterations: parallelism) { iteration in
			let start = iteration * Coord.count / parallelism
			let end = (iteration + 1) * Coord.count / parallelism
			
			performSearch(through: start..<end)
		}
	}
	
	func performSearch(through indexRange: Range<Int>) {
		var statesReached: Int32 = 0
		defer { OSAtomicAdd32(statesReached, &self.statesReached) }
		
		for index in indexRange {
			guard distances[index] == distanceToSearch else { continue }
			// takes ~160 ns per entry (80 ns on my iPhone 11 Pro Max)
			
			let coord = Coord(index)
			let neighbors = Coord.allowedMoves.lazy.map { coord + $0 }
			if isSearchingForwards {
				for neighbor in neighbors {
					let index = neighbor.intValue
					guard distances[index] == .max else { continue }
					
					distances[index] = distance
					statesReached += 1
					
					let representant = neighbor.symmetryCoord.representant
					if representant.hasSymmetries { // applies to ~3% of values
						for symmetry in StandardSymmetry.all.dropFirst() where representant.hasSymmetry(symmetry) {
							let shifted = neighbor.shifted(with: symmetry)
							guard distances[shifted.intValue] == .max else { continue }
							distances[shifted.intValue] = distance
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
	}
}
