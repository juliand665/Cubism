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
	
	func sumWithIncreasingBases(firstBase: Int = 1) -> Element {
		self // todo: zip with bases instead
			.enumerated()
			.reversed()
			.reduce(0) { sum, new in
				let base = new.offset + firstBase
				assert(new.element < base)
				return sum * base + new.element
			}
	}
}

extension RandomAccessCollection where Element: Comparable {
	func binarySearch(for target: Element) -> Index? {
		let candidate = partitioningIndex { $0 >= target }
		guard candidate < endIndex, self[candidate] == target else { return nil }
		return candidate
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
	
	func digitsWithIncreasingBases(count: Self, firstBase: Self = 1) -> [Self] {
		(0..<count) // bases
			.map(state: self) { rest, base in
				let remainder: Self
				(rest, remainder) = rest.quotientAndRemainder(dividingBy: base + firstBase)
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
