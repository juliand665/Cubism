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

let testCornerPerm = CornerPermutation(
	urf: .dfr, ufl: .ufl, ulb: .ulb, ubr: .urf,
	dfr: .drb, dlf: .dlf, dbl: .dbl, drb: .ubr
)
print(testCornerPerm.coordinate())

let testCornerOrientation = CornerOrientations(
	urf: .twistedCCW, ufl: .neutral, ulb: .neutral, ubr: .twistedCW,
	dfr: .twistedCW, dlf: .neutral, dbl: .neutral, drb: .twistedCCW
)
print(testCornerOrientation.coordinate())

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
print(u + r + ui + ri == -sexyMove)
print(tripleSexy - tripleSexy)
print(cubeInACube)
print(cubeInACube + cubeInACube)
print(cubeInACube + cubeInACube + cubeInACube)
