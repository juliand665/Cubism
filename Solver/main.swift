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
		let dumbSequence = lessDumbSequence.reductions(.zero, +)
		let prefixUntilLoop = dumbSequence
			.enumerated()
			.dropFirst()
			.prefix { $0.element != .zero }
		let uniques = Set(prefixUntilLoop.map(\.element))
		print(uniques.count, "unique states")
		print(
			dumbSequence
				.enumerated()
				.dropFirst()
				.first { $0.element == .zero }!
		)
	}
}
//testSequences()

// MARK: -

func timeStuff() {
	func measureTime(repetitions: Int = 1_000_000, for block: () -> Void) {
		let start = Date()
		for _ in 1...repetitions {
			block()
		}
		print("done in", -start.timeIntervalSinceNow)
	}
	
	let testSize = 20
	let test = Array(0..<testSize).sumWithIncreasingBases()
	
	print("starting")
	measureTime { _ = test.digitsWithIncreasingBases(count: testSize) }
}
//timeStuff()

// MARK: -

func testCoordCalculations() {
	let testCornerOrientation = CornerOrientations(
		urf: .twistedCCW, ufl: .neutral, ulb: .neutral, ubr: .twistedCW,
		dfr: .twistedCW, dlf: .neutral, dbl: .neutral, drb: .twistedCCW
	)
	print(testCornerOrientation.coordinate())
	
	for rawCoord in 0..<CornerOrientationCoordinate.Space.count {
		let coord = CornerOrientationCoordinate(rawCoord)
		let orientation = CornerOrientations(coordinate: coord)
		precondition(coord == orientation.coordinate())
	}
	
	for rawCoord in 0..<CornerPermutationCoordinate.Space.count {
		let coord = CornerPermutationCoordinate(rawCoord)
		let orientation = CornerPermutation(coordinate: coord)
		precondition(coord == orientation.coordinate())
	}
}
testCoordCalculations()

// MARK: -

struct SolverMove {
	static let all = Face.allCases.flatMap { face -> [Self] in
		let transform = CubeTransformation.transform(for: face)
		let variants = sequence(first: transform) { $0 + transform }
		return zip(Move.Direction.inCWOrder, variants).map { direction, transform in
			Self(
				move: .init(target: .singleFace(face), direction: direction),
				transform: transform
			)
		}
	}
	
	var move: Move
	var transform: CubeTransformation
}
