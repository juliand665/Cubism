import Foundation
import Algorithms
import HandyOperators

extension Sequence {
	func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		try lazy.filter(isIncluded).count
	}
	
	func map<State, T>(
		state: State,
		_ transform: (inout State, Element) throws -> T
	) rethrows -> [T] {
		var state = state
		return try map { try transform(&state, $0) }
	}
}

extension Sequence where Element: AdditiveArithmetic {
	func sum() -> Element {
		reduce(.zero, +)
	}
}

extension Sequence where Element == Int {
	func product() -> Element {
		reduce(1, *)
	}
	
	func sumWithIncreasingBases() -> Element {
		self
			.enumerated()
			.reversed()
			.reduce(0) { sum, new in
				let base = new.offset + 1
				assert(new.element < base)
				return sum * base + new.element
			}
	}
}

extension BinaryInteger where Stride: SignedInteger {
	func digits(withBase base: Self) -> [Self] {
		Array(sequence(state: self) { rest -> Self? in
			guard rest > 0 else { return nil }
			let remainder: Self
			(rest, remainder) = rest.quotientAndRemainder(dividingBy: base)
			return remainder
		}).reversed()
	}
	
	func digitsWithIncreasingBases(count: Self) -> [Self] {
		var rest = self
		return (1...count) // bases
			.map { base in
				let remainder: Self
				(rest, remainder) = rest.quotientAndRemainder(dividingBy: base)
				return remainder
			}
	}
	
	func digitsWithIncreasingBases2(count: Self) -> [Self] {
		(1...count) // bases
			.map(state: self) { rest, base in
				let remainder: Self
				(rest, remainder) = rest.quotientAndRemainder(dividingBy: base)
				return remainder
			}
	}
}

protocol AdditiveArithmeticWithNegation: AdditiveArithmetic {
	static prefix func - (perm: Self) -> Self
}

extension AdditiveArithmeticWithNegation {
	static func - (lhs: Self, rhs: Self) -> Self {
		lhs + -rhs
	}
}

struct SolverMove {
	static let all = Face.allCases.flatMap { face -> [Self] in
		let transform = CubeTransformation.transform(for: face)
		let variants = sequence(first: transform) { $0 + transform }
		let directions = [Move.Direction.clockwise, .double, .counterclockwise]
		return zip(directions, variants).map { direction, transform in
			Self(
				move: .init(target: .singleFace(face), direction: direction),
				transform: transform
			)
		}
	}
	
	var move: Move
	var transform: CubeTransformation
}

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
print(u + r + ui + ri == -sexyMove)
print(r + u - r - u == r + u + ri + ui)
print(tripleSexy - tripleSexy)
print(cubeInACube)
print(cubeInACube + cubeInACube)
print(cubeInACube + cubeInACube + cubeInACube)
*/

/*
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
*/

/*
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
*/

/*
let testOrientation = CornerOrientations(ulb: .twistedCCW, ubr: .twistedCW, dbl: .twistedCW, drb: .twistedCCW)
let coord = testOrientation.coordinate()
print(coord)

for rawCoord in 0..<CornerOrientationCoordinate.Space.count {
	let coord = CornerOrientationCoordinate(rawCoord)
	let orientation = CornerOrientations(coordinate: coord)
	precondition(coord == orientation.coordinate())
}
*/

let digits = [0, 1, 1, 3, 0, 1, 1, 4]
let sum = digits.sumWithIncreasingBases()
print(sum)
print(sum.digitsWithIncreasingBases(count: digits.count))

let testCornerPerm = CornerPermutation(
	urf: .dfr, ufl: .ufl, ulb: .ulb, ubr: .urf,
	dfr: .drb, dlf: .dlf, dbl: .dbl, drb: .ubr
)
let array = testCornerPerm.asArray()
let coord = testCornerPerm.coordinate()
print(coord)
print(array)
let newArray = Corner.allCases.reorderedToMatch(coord)
print(newArray)

print(MemoryLayout<EdgePermutation>.size)
print(MemoryLayout<CornerPermutation>.size)
print(MemoryLayout<EdgeOrientations>.size)
print(MemoryLayout<CornerOrientations>.size)

/*
let testCornerOrientation = CornerOrientations(
	urf: .twistedCCW, ufl: .neutral, ulb: .neutral, ubr: .twistedCW,
	dfr: .twistedCW, dlf: .neutral, dbl: .neutral, drb: .twistedCCW
)
print(testCornerOrientation.coordinate())
*/

/*
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
measureTime { _ = test.digitsWithIncreasingBases2(count: testSize) }
*/
