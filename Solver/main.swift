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

func runTests(on start: CubeTransformation) {
	_ = ReducedFlipUDSliceCoordinate.moveTable
	print(start.edges)
	let startCoord = ReducedFlipUDSliceCoordinate(start.edges)
	print(startCoord, startCoord.symmetry.inverse)
	print(startCoord.makeState())
	print(FlipUDSliceCoordinate(start.edges))
	let representant = ReducedFlipUDSliceCoordinate.representants[Int(startCoord.index)]
	print(representant)
	
	print()
	//print(FlipUDSliceCoordinate(start.edges))
	//print(FlipUDSliceCoordinate(startCoord.makeState()))
	//print(startCoord.makeState())
	//print(start.edges)
	let move = SolverMove.resolving(face: .right, direction: .clockwise)
	let shiftedMove = startCoord.symmetry.shift(move)
	print("shifted:", shiftedMove)
	let fromTable = ReducedFlipUDSliceCoordinate.moveTable[startCoord][shiftedMove]
	print("from table:", fromTable)
	print(startCoord.symmetry + fromTable.symmetry, fromTable.symmetry + startCoord.symmetry)
	let endCoord = startCoord + move
	
	let end = start + move.transform
	let groundTruth = ReducedFlipUDSliceCoordinate(end.edges)
	print("are equal: ", endCoord == groundTruth)
	print("computed:  ", endCoord)
	print("gt:        ", groundTruth)
	let fromCoord = FlipUDSliceCoordinate(startCoord.makeState() + move.transform)
	print("from coord:", fromCoord)
	print("reduced:   ", ReducedFlipUDSliceCoordinate(fromCoord))
	print("representant:", ReducedFlipUDSliceCoordinate.representants[Int(endCoord.index)])
	print("recreated:   ", FlipUDSliceCoordinate(endCoord.makeState()))
	print("raw gt:      ", FlipUDSliceCoordinate(end.edges))
	print()
	print()
}
/*
runTests(on: CubeTransformation.zero)
print("ri")
runTests(on: ri)
print("fi")
runTests(on: fi)
print("sexy")
runTests(on: sexyMove)
*/

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
	let orientation = transform.edges.orientation
	print(transform)
	for symmetry in Symmetry.standardSubgroup {
		print()
		let full = symmetry.shift(transform).edges.orientation
		let small = symmetry.shift(orientation)
		print(symmetry.shift(transform).edges.permutation)
		print(symmetry.shift(transform).edges.orientation)
		print(small)
		print(full == small)
		print((symmetry.forward + transform).edges.permutation)
		print((symmetry.forward + transform).edges.orientation)
		print(symmetry.forward + orientation)
		print((transform + symmetry.backward).edges.permutation)
		print((transform + symmetry.backward).edges.orientation)
		print(orientation + symmetry.backward)
		print(symmetry.forward)
		//print(symmetry.forward)
		//print(CubeTransformation(edges.orientation: symmetry.shift(simple)))
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

func timeStuff() {
	let testSize = 20
	let test = Array(0..<testSize).sumWithIncreasingBases()
	
	print("starting")
	benchmark(repetitions: 1_000_000) { test.digitsWithIncreasingBases(count: testSize) }
}
//timeStuff()

// MARK: -

func testCoordCalculations() {
	func test<Coord: SimpleCoordinate>(_ coord: Coord.Type) {
		print("Testing \(Coord.self)…")
		for rawCoord in 0..<Coord.countAsValue {
			// print progress when these bits are zero:
			let bitsToCheck = Coord.Value((1 << 16) - 1)
			if rawCoord & bitsToCheck == 0 {
				let progress = Double(rawCoord) / Double(Coord.count)
				print("\(100 * progress)%")
			}
			let coord = Coord(rawCoord)
			let state = coord.makeState()
			precondition(coord == Coord(state))
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

struct PruningTable<Coord: CoordinateWithMoves> {
	var distances: [UInt8]
	
	init() {
		distances = .init(repeating: .max, count: Coord.count)
		
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
					
					let coord = Coord(index)
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
	_ = UDSliceCoordinate.standardSymmetryTable
	_ = EdgeOrientationCoordinate.standardSymmetryTable
	let representants = ReducedFlipUDSliceCoordinate.representants
	print(representants.count, "representants")
	print()
	_ = ReducedFlipUDSliceCoordinate.moveTable
	
	let table = PruningTable<Phase1Coordinate>()
	_ = table
}
setUpTables()
