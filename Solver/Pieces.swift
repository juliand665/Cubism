protocol CubePiece: Hashable, Comparable, CaseIterable, RawRepresentable
where AllCases: RandomAccessCollection, RawValue == Int {
	var name: String { get }
}

extension CubePiece {
	static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

enum Corner: Int, CubePiece, Comparable, CaseIterable {
	case urf, ufl, ulb, ubr
	case dfr, dlf, dbl, drb
	
	var name: String {
		String(describing: self).uppercased()
	}
}

enum Edge: Int, CubePiece, Comparable, CaseIterable {
	case ur, uf, ul, ub
	case dr, df, dl, db
	case fr, fl, bl, br
	
	var name: String {
		String(describing: self).uppercased()
	}
}

protocol PartialCubeState: AdditiveArithmeticWithNegation {
	static func + (transform: CubeTransformation, state: Self) -> Self
	static func + (state: Self, transform: CubeTransformation) -> Self
	static func += (state: inout Self, transform: CubeTransformation)
}

extension PartialCubeState {
	static func += (state: inout Self, transform: CubeTransformation) {
		state = state + transform
	}
}

protocol PartialCornerState: PartialCubeState {
	static func + (transform: CubeTransformation.Corners, state: Self) -> Self
	static func + (state: Self, transform: CubeTransformation.Corners) -> Self
}

extension PartialCornerState {
	static func + (transform: CubeTransformation, state: Self) -> Self {
		transform.corners + state
	}
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state + transform.corners
	}
}

protocol PartialEdgeState: PartialCubeState {
	static func + (transform: CubeTransformation.Edges, state: Self) -> Self
	static func + (state: Self, transform: CubeTransformation.Edges) -> Self
}

extension PartialEdgeState {
	static func + (transform: CubeTransformation, state: Self) -> Self {
		transform.edges + state
	}
	
	static func + (state: Self, transform: CubeTransformation) -> Self {
		state + transform.edges
	}
}

extension Array where Element == SolverMove {
	static var all: Self { SolverMove.all }
	static var phase1Preserving: Self { SolverMove.phase1Preserving }
}

struct SolverMove: CustomStringConvertible {
	static let all = Action.all
		.map { Self(action: $0, transform: transforms[$0]) }
	static let phase1Preserving = Action.phase1Preserving
		.map { Self(action: $0, transform: transforms[$0]) }
	static let transforms = SolverMoveMap<CubeTransformation> { (face: Face) in
		let clockwise = CubeTransformation.transform(for: face)
		let double = clockwise + clockwise
		let counterclockwise = double + clockwise
		return .init(
			clockwise: clockwise,
			double: double,
			counterclockwise: counterclockwise
		)
	}
	static let byTransform = Dictionary(
		uniqueKeysWithValues: all.map { ($0.transform, $0) }
	)
	
	var action: Action
	var transform: CubeTransformation
	
	var description: String {
		"SolverMove(\(action))"
	}
	
	static prefix func - (move: Self) -> Self {
		.init(action: -move.action, transform: -move.transform)
	}
	
	struct Action: Hashable, CustomStringConvertible {
		static let all = Face.allCases.flatMap { face in
			Move.Direction.allCases.map { Self(face: face, direction: $0) }
		}
		
		static let phase1Preserving = all.filter {
			switch $0.face {
			case .up, .down:
				return true
			case .front, .right, .back, .left:
				return $0.direction == .double
			}
		}
		
		var face: Face
		var direction: Move.Direction
		
		var move: Move {
			.init(target: .singleFace(face), direction: direction)
		}
		
		var transform: CubeTransformation {
			SolverMove.transforms[self]
		}
		
		var resolved: SolverMove {
			.init(action: self, transform: transform)
		}
		
		var description: String {
			StandardNotation.description(for: move)
		}
		
		static prefix func - (action: Self) -> Self {
			.init(face: action.face, direction: -action.direction)
		}
	}
}

extension SolverMove {
	static func resolving(face: Face, direction: Move.Direction) -> Self {
		Action(face: face, direction: direction).resolved
	}
}
