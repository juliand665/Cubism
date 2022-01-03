import SwiftUI

extension Move.Target {
	var color: Color {
		switch self {
		case .singleFace(let face), .doubleFace(let face), .wideTurn(let face, _), .bigSlice(let face, _):
			return face.color
		case .slice(let slice):
			return slice.color
		case .rotation:
			return .gray
		}
	}
	
	var hasMultipleLayers: Bool {
		switch self {
		case .doubleFace, .wideTurn:
			return true
		case .singleFace, .slice, .bigSlice, .rotation:
			return false
		}
	}
}

extension Slice {
	var color: Color {
		switch self {
		case .behindDown:
			return .brown
		case .behindLeft:
			return .teal
		case .behindFront:
			return .purple
		}
	}
}

extension Face {
	var color: Color {
		switch self {
		case .front:
			return .red
		case .back:
			return .orange
		case .up:
			return .yellow
		case .down:
			return .primary
		case .left:
			return .blue
		case .right:
			return .green
		}
	}
}
