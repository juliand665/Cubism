protocol CubePiece: Comparable, CaseIterable {
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

struct SolverMove {
	static let all = Face.allCases.flatMap { face -> [Self] in
		let transform = CubeTransformation.transform(for: face)
		let variants = sequence(first: transform) { $0 + transform }
		return zip(Move.Direction.inCWOrder, variants).map { direction, transform in
			Self(
				face: face,
				direction: direction,
				transform: transform
			)
		}
	}
	
	var face: Face
	var direction: Move.Direction
	var transform: CubeTransformation
	
	var move: Move {
		.init(target: .singleFace(face), direction: direction)
	}
}
