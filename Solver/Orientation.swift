import Foundation

enum CornerOrientation: Int, CaseIterable {
	case neutral
	case twistedCW
	case twistedCCW
}

extension CornerOrientation: AdditiveArithmetic {
	static var zero = neutral
	
	static func + (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.neutral, let other), (let other, .neutral):
			return other
		case (.twistedCW, .twistedCW):
			return .twistedCCW
		case (.twistedCW, .twistedCCW), (.twistedCCW, .twistedCW):
			return .neutral
		case (.twistedCCW, .twistedCCW):
			return .twistedCW
		}
	}
	
	static func - (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (let other, .neutral):
			return other
		case (.twistedCW, .twistedCW), (.twistedCCW, .twistedCCW):
			return .neutral
		case (.twistedCW, .twistedCCW), (.neutral, .twistedCW):
			return .twistedCCW
		case (.twistedCCW, .twistedCW), (.neutral, .twistedCCW):
			return .twistedCW
		}
	}
	
	static prefix func - (orientation: Self) -> Self {
		switch orientation {
		case .neutral:
			return .neutral
		case .twistedCW:
			return .twistedCCW
		case .twistedCCW:
			return .twistedCW
		}
	}
}

enum EdgeOrientation: Int, CaseIterable {
	case neutral
	case flipped
}

extension EdgeOrientation: AdditiveArithmeticWithNegation {
	static var zero = neutral
	
	static func + (lhs: Self, rhs: Self) -> Self {
		switch (lhs, rhs) {
		case (.neutral, let other), (let other, .neutral):
			return other
		case (.flipped, .flipped):
			return .neutral
		}
	}
	
	static func - (lhs: Self, rhs: Self) -> Self {
		lhs + rhs
	}
	
	static prefix func - (orientation: Self) -> Self { orientation }
}
