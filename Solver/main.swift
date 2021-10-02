import Foundation

extension Sequence {
	func count(where isIncluded: (Element) throws -> Bool) rethrows -> Int {
		try lazy.filter(isIncluded).count
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
