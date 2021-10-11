import Foundation

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
	
	func filter<State>(
		state: State,
		_ shouldInclude: (inout State, Element) throws -> Bool
	) rethrows -> [Element] {
		var state = state
		return try filter { try shouldInclude(&state, $0) }
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