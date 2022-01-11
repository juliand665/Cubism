protocol CubePiece: Comparable, CaseIterable where AllCases: RandomAccessCollection {
	var name: String { get }
}

enum Corner: CubePiece, Comparable, CaseIterable {
	case urf, ufl, ulb, ubr
	case dfr, dlf, dbl, drb
	
	var name: String {
		String(describing: self).uppercased()
	}
}

enum Edge: CubePiece, Comparable, CaseIterable {
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

struct SolverMove: CustomStringConvertible {
	static let all = Action.all.map { Self(action: $0, transform: transforms[$0]) }
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
	
	struct Action: Hashable, CustomStringConvertible {
		static let all = Face.allCases.flatMap { face in
			Move.Direction.allCases.map { Self(face: face, direction: $0) }
		}
		
		var face: Face
		var direction: Move.Direction
		
		var move: Move {
			.init(target: .singleFace(face), direction: direction)
		}
		
		var resolved: SolverMove {
			.init(action: self, transform: SolverMove.transforms[self])
		}
		
		var description: String {
			StandardNotation.description(for: move)
		}
	}
}

extension SolverMove {
	static func resolving(face: Face, direction: Move.Direction) -> Self {
		Action(face: face, direction: direction).resolved
	}
}
