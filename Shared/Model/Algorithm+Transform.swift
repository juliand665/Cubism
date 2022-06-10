import Foundation
import HandyOperators

extension MoveSequence {
	func transform() throws -> CubeTransformation {
		try moves
			.map { try $0.transform ??? TransformError.noTransform($0) }
			.reduce(.zero, +)
	}
	
	func transformReversingRotations() throws -> CubeTransformation {
		let transform = try transform()
		let rotationTransform = moves
			.compactMap(\.rotationMove)
			.map { $0.transform! }
			.reduce(.zero, +)
		return transform - rotationTransform
	}
	
	enum TransformError: Error {
		case noTransform(Move)
	}
}

extension Move {
	var transform: CubeTransformation? {
		guard let single = target.transform else { return nil }
		switch direction {
		case .clockwise:
			return single
		case .double:
			return single + single
		case .counterclockwise:
			return -single
		}
	}
}

extension Move.Target {
	var transform: CubeTransformation? {
		switch self {
		case .singleFace(let face):
			return .transform(for: face)
		case .doubleFace(let face), .wideTurn(let face, sliceCount: _):
			return .transformForWideTurn(of: face)
		case .slice(let slice):
			switch slice {
			case .behindDown:
				return .sliceBehindD
			case .behindLeft:
				return .sliceBehindL
			case .behindFront:
				return .sliceBehindF
			}
		case .rotation(let rotation):
			switch rotation {
			case .x:
				return .xRotation
			case .y:
				return .yRotation
			case .z:
				return .zRotation
			}
		default:
			return nil
		}
	}
	
	var rotation: (rotation: FullCubeRotation, isInverted: Bool)? {
		switch self {
		case .rotation(let rotation):
			return (rotation, isInverted: false)
		case .doubleFace(let face), .wideTurn(let face, sliceCount: _):
			switch face {
			case .front:
				return (.z, isInverted: false)
			case .back:
				return (.z, isInverted: true)
			case .up:
				return (.y, isInverted: false)
			case .down:
				return (.y, isInverted: true)
			case .right:
				return (.x, isInverted: false)
			case .left:
				return (.x, isInverted: true)
			}
		case .slice(let slice):
			switch slice {
			case .behindFront:
				return (.z, isInverted: false)
			case .behindDown:
				return (.y, isInverted: true)
			case .behindLeft:
				return (.x, isInverted: true)
			}
		default:
			return nil
		}
	}
}

extension Move {
	var rotationMove: Self? {
		target.rotation.map {
			.init(
				target: .rotation($0.rotation),
				direction: $0.isInverted ? -direction : direction
			)
		}
	}
}
