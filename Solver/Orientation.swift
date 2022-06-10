protocol SinglePieceOrientation: Hashable, CaseIterable, AdditiveArithmeticWithNegation, RawRepresentable where RawValue == Int {
	associatedtype Piece: CubePiece
}

enum SingleCornerOrientation: Int, SinglePieceOrientation, Codable {
	typealias Piece = Corner
	
	case neutral
	case twistedCW
	case twistedCCW
}

extension SingleCornerOrientation: AdditiveArithmeticWithNegation {
	static let zero = neutral
	
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

enum SingleEdgeOrientation: Int, SinglePieceOrientation {
	typealias Piece = Edge
	
	case neutral
	case flipped
}

extension SingleEdgeOrientation: AdditiveArithmeticWithNegation {
	static let zero = neutral
	
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
