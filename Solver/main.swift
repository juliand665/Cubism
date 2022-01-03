import Foundation
import Algorithms
import HandyOperators

let u = CubeTransformation.upTurn
let f = CubeTransformation.frontTurn
let r = CubeTransformation.rightTurn
let d = CubeTransformation.downTurn
let b = CubeTransformation.backTurn
let l = CubeTransformation.leftTurn
let uu = u + u
let ff = f + f
let rr = r + r
let dd = d + d
let bb = b + b
let ll = l + l
let ui = uu + u
let fi = ff + f
let ri = rr + r
let di = dd + d
let bi = bb + b
let li = ll + l

let sexyMove = r + u + ri + ui
let tripleSexy = sexyMove + sexyMove + sexyMove
let tPerm = sexyMove + ri + f + rr + ui + ri + ui + r + u + ri + fi
let cubeInACube = f + l + f + ui + r + u + ff + ll + ui + li + b + di + bi + ll + u

/*
let f2 = CubeTransformation.symmetryF2
let lr = CubeTransformation.symmetryLR2
print(f2 - f2)
print(f2 + f2)
print(f2 + sexyMove + f2)
print(lr - lr)
print(lr + lr)
print(lr + sexyMove + lr)
print()
*/

func playWithSymmetries() {
	//let simple = EdgeOrientation(uf: .flipped)
	//let orientation = EdgeOrientation(uf: .flipped, dr: .flipped, fl: .flipped)
	//let transform = CubeTransformation(edgeOrientation: orientation)
	let transform = sexyMove
	let orientation = transform.edgeOrientation
	print(transform)
	for symmetry in Symmetry.standardSubgroup {
		print()
		let full = symmetry.shift(transform).edgeOrientation
		let small = symmetry.shift(orientation)
		print(symmetry.shift(transform).edgePermutation)
		print(symmetry.shift(transform).edgeOrientation)
		print(small)
		print(full == small)
		print((symmetry.forward + transform).edgePermutation)
		print((symmetry.forward + transform).edgeOrientation)
		print(symmetry.forward + orientation)
		print((transform + symmetry.backward).edgePermutation)
		print((transform + symmetry.backward).edgeOrientation)
		print(orientation + symmetry.backward)
		print(symmetry.forward)
		//print(symmetry.forward)
		//print(CubeTransformation(edgeOrientation: symmetry.shift(simple)))
	}
}
//playWithSymmetries()

// MARK: -

func testCoordinates() {
	print(EdgePermutation().udSliceCoordinate())
	print()
	
	let worstEdgePerm = EdgePermutation(ur: .fr, uf: .fl, ul: .bl, ub: .br, fr: .ur, fl: .uf, bl: .ul, br: .ub)
	print(worstEdgePerm.udSliceCoordinate())
	print()
	
	let testEdgePerm = EdgePermutation(ub: .fr, dl: .bl, fr: .ub, bl: .dl)
	print(testEdgePerm.udSliceCoordinate())
	print()
	
	let testEdgePerm2 = EdgePermutation(uf: .bl, dr: .br, bl: .uf, br: .dr)
	print(testEdgePerm2.udSliceCoordinate())
	print()
}
//testCoordinates()

// MARK: -

func testSequences() {
	//let lessDumbSequence = repeatElement([r, l, u, d, f, b], count: .max).lazy.joined()
	for _ in 1...10 {
		print()
		let randomCombo = (1...10_000).map { _ in [u, r, f, l, b, d].randomElement()! }//.reduce(.zero, +)
		//print(randomCombo)
		let lessDumbSequence = repeatElement(randomCombo, count: .max).lazy.joined()
		let dumbSequence = lessDumbSequence.reductions(+)
		let prefixUntilLoop = dumbSequence
			.enumerated()
			.prefix { $0.element != .zero }
		let uniques = Set(prefixUntilLoop.map(\.element))
		print(uniques.count, "unique states")
		print(
			dumbSequence
				.enumerated()
				.first { $0.element == .zero }!
		)
	}
}
//testSequences()

// MARK: -

func measureTime<Result>(as title: String? = nil, for block: () throws -> Result) rethrows -> Result {
	if let title = title {
		print("measuring \(title)…")
	}
	
	let start = Date()
	let result = try block()
	let timeTaken = -start.timeIntervalSinceNow
	let formatter = NumberFormatter() <- { $0.minimumFractionDigits = 6 }
	print("done in \(formatter.string(from: timeTaken as NSNumber)!)s")
	print()
	return result
}

func benchmark<T>(as title: String? = nil, repetitions: Int, for block: () -> T) -> Void {
	measureTime(as: title.map { "\(repetitions)x \($0)" }) {
		for _ in 1...repetitions {
			_ = block()
		}
	}
}

func timeStuff() {
	let testSize = 20
	let test = Array(0..<testSize).sumWithIncreasingBases()
	
	print("starting")
	benchmark(repetitions: 1_000_000) { test.digitsWithIncreasingBases(count: testSize) }
}
//timeStuff()

// MARK: -

func testCoordCalculations() {
	func test<Space: CoordinateSpace>(_ coord: Coordinate<Space>.Type) {
		print("Testing \(Space.self)…")
		for rawCoord in 0..<Space.count {
			// print progress when these bits are zero:
			let bitsToCheck = Space.Value((1 << 16) - 1)
			if rawCoord & bitsToCheck == 0 {
				let progress = Double(rawCoord) / Double(Space.count)
				print("\(100 * progress)%")
			}
			let coord = Space.Coord(rawCoord)
			let state = coord.makeState()
			precondition(coord == Space.Coord(state))
		}
		print("Test succeeded!")
	}
	
	test(UDSliceCoordinate.self)
	test(CornerOrientationCoordinate.self)
	test(CornerPermutationCoordinate.self)
	test(EdgeOrientationCoordinate.self)
	test(EdgePermutationCoordinate.self) /// 12! states takes forever zzz
}
//testCoordCalculations()

// MARK: -

struct PruningTable<Space: CoordinateSpaceWithMoves> {
	var distances: [UInt8]
	
	init() {
		distances = .init(repeating: .max, count: Int(Space.count))
		
		print("setting up pruning table")
		distances[0] = 0
		var distance: UInt8 = 1
		var statesReached = 1
		//var searching: Set<Space.Coord> = [.init(0)]
		while statesReached < distances.count {
			measureTime(as: "search at distance \(distance)") {
				let statesReachedBefore = statesReached
				defer {
					print("\(statesReached - statesReachedBefore) new states reached")
				}
				
				let isSearchingForwards = statesReached < distances.count / 2
				print(isSearchingForwards ? "searching forwards" : "searching backwards")
				let distanceToSearch = isSearchingForwards ? distance - 1 : .max
				
				//var nextUp: Set<Space.Coord> = []
				for index in distances.indices {
					guard distances[index] == distanceToSearch else { continue }
					
					let coord = Space.Coord(index)
					let neighbors = SolverMove.all.lazy.map { coord + $0 }
					if isSearchingForwards {
						for neighbor in neighbors where distances[neighbor.intValue] == .max {
							distances[neighbor.intValue] = distance
							statesReached += 1
						}
						//nextUp.formUnion(SolverMove.all.map { toSearch + $0 })
					} else {
						let isReachable = neighbors.contains { distances[$0.intValue] == distance - 1 }
						guard isReachable else { continue }
						distances[index] = distance
						statesReached += 1
					}
				}
				
				//searching = nextUp
				distance += 1
			}
		}
	}
}

/*
typealias BaseCoord = FlipUDSliceCoordinate
let coord = BaseCoord(2048)
let (udSlice, orientation) = coord.components
let symmetries = zip(udSlice.standardSymmetries, orientation.standardSymmetries)
let state = coord.makeState()
print()
print()
print()
print(coord)
print(state)
print()

for ((index, (udSlice, edgeOri)), symmetry) in zip(symmetries.enumerated(), Symmetry.standardSubgroup) {
	let slow = symmetry.shift(state)
	print(index)
	print("ground truth:", slow)
	//let perm = udSlice.makeState()
	let ori = state.edgeOrientation
	//print(symmetry.shift(perm))
	print("ori only:", symmetry.shift(ori))
	print("ori wrapped:", symmetry.shift(CubeTransformation(edgeOrientation: ori)))
	let coord = BaseCoord(udSlice, edgeOri)
	//print("fast result:", coord.makeState())
	let slowCoord = BaseCoord(slow)
	
	print(coord, slowCoord)
	precondition(coord == slowCoord)
}
 */

func setUpTables() {
	_ = UDSliceCoordinate.Space.standardSymmetryTable
	_ = EdgeOrientationCoordinate.Space.standardSymmetryTable
	_ = FlipUDSliceCoordinate.Space.standardSymmetryTable
	let representants = ReducedFlipUDSliceCoordinate.Space.representants
	print(representants.count, "representants")
	print()
	_ = ReducedFlipUDSliceCoordinate.Space.moveTable
	
	let table = PruningTable<Phase1Coordinate.Space>()
	_ = table
}
//setUpTables()
