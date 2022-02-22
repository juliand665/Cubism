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
	let representant = startCoord.representant
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
	print(startCoord.symmetry * fromTable.symmetry, fromTable.symmetry * startCoord.symmetry)
	let endCoord = startCoord + move
	
	let end = start + move.transform
	let groundTruth = ReducedFlipUDSliceCoordinate(end.edges)
	print("are equal: ", endCoord == groundTruth)
	print("computed:  ", endCoord)
	print("gt:        ", groundTruth)
	let fromCoord = FlipUDSliceCoordinate(startCoord.makeState() + move.transform)
	print("from coord:", fromCoord)
	print("reduced:   ", ReducedFlipUDSliceCoordinate(fromCoord))
	print("representant:", endCoord.representant)
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

measureTime(as: "initializing") {
	BasicTwoPhaseSolver(start: r + f).searchNextLevel()
}

print()

/*
let scramble1 = b + ri + ff + dd + li + bb + l + uu + r + ff + rr + bb + ri + bi + li + ff + di + b + ll + ff
let solution1 = scramble1.solve()
print("solution found!", solution1)

print()

let scramble2 = f + r + dd + r + l + ui + li + ui + d + b + dd + b + rr + uu + fi + rr + fi + dd + ff + rr
let solution2 = scramble2.solve()
print("solution found!", solution2)

print()
print("cube in a cube:", cubeInACube.solve())
print("cube in a cube reversed:", (-cubeInACube).solve())
*/

// TODO: compare to basic solver
let solvers = (1...1000).map { _ in ThreeWayTwoPhaseSolver(start: .random()) }
for depth in 1... {
	print()
	measureTime {
		solvers.forEach { $0.searchNextLevel() }
	}
	let lengths = solvers.map(\.bestSolution!.length)
	let lengthCounts: [Int: Int] = lengths.reduce(into: [:]) { $0[$1, default: 0] += 1 }
	print("depth \(depth):")
	print(
		lengthCounts
			.sorted { $0.key < $1.key }
			.map { "length \($0): \($1)x" }
			.joined(separator: "\n")
	)
}
