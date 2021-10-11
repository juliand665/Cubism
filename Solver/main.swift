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

func measureTime(as title: String? = nil, repetitions: Int = 1, for block: () -> Void) {
	if let title = title {
		print("measuring \(title)…")
	}
	
	let start = Date()
	for _ in 1...repetitions {
		block()
	}
	let timeTaken = -start.timeIntervalSinceNow
	let formatter = NumberFormatter() <- { $0.minimumFractionDigits = 6 }
	print("done in \(formatter.string(from: timeTaken as NSNumber)!)s")
	print()
}

func timeStuff() {
	
	let testSize = 20
	let test = Array(0..<testSize).sumWithIncreasingBases()
	
	print("starting")
	measureTime(repetitions: 1_000_000) { _ = test.digitsWithIncreasingBases(count: testSize) }
}
//timeStuff()

// MARK: -

func testCoordCalculations() {
	func test<Space: CoordinateSpace>(_ coord: Coordinate<Space>.Type) {
		print("Testing \(Space.self)…")
		for rawCoord in 0..<Space.count {
			if rawCoord & ((1 << 16) - 1) == 0 {
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

let udSliceSymMoves = StandardSymmetryTable<UDSliceCoordinate.Space>()
let edgeOriSymMoves = StandardSymmetryTable<EdgeOrientationCoordinate.Space>()

let flipUDSliceRepresentants = FlipUDSliceCoordinate.allValues
	.filter(state: Array(repeating: false, count: FlipUDSliceCoordinate.Space.count)) { seen, coord in
		guard !seen[coord.intValue] else { return false }
		
		let udSliceSymmetries = udSliceSymMoves[coord.udSliceCoord].moves
		let orientationSymmetries = edgeOriSymMoves[coord.edgeOrientationCoord].moves
		for (udSlice, edgeOri) in zip(udSliceSymmetries, orientationSymmetries) {
			let coord = FlipUDSliceCoordinate(udSlice, edgeOri)
			seen[coord.intValue] = true
		}
		
		return true
	}

print("found \(flipUDSliceRepresentants.count) equivalence classes")
