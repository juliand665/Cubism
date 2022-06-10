/// Expresses anything you can do to the cube. Either interpreted as a transformation of the cube relative to another state, or as a state (a transformation relative to the solved state).
struct CubeTransformation: Hashable {
	var corners = Corners()
	var edges = Edges()
	
	struct Corners: PieceTransformation {
		var permutation = CornerPermutation()
		var orientation = CornerOrientation()
	}
	
	struct Edges: PieceTransformation {
		var permutation = EdgePermutation()
		var orientation = EdgeOrientation()
	}
}

protocol PieceTransformation: Hashable {}

extension CubeTransformation {
	init(
		cornerPermutation: CornerPermutation = .init(),
		cornerOrientation: CornerOrientation = .init(),
		edgePermutation: EdgePermutation = .init(),
		edgeOrientation: EdgeOrientation = .init()
	) {
		self.init(
			corners: .init(permutation: cornerPermutation, orientation: cornerOrientation),
			edges: .init(permutation: edgePermutation, orientation: edgeOrientation)
		)
	}
}

extension CubeTransformation: PartialCubeState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			corners: one.corners + two.corners,
			edges: one.edges + two.edges
		)
	}
	
	static prefix func - (t: Self) -> Self {
		.init(
			corners: -t.corners,
			edges: -t.edges
		)
	}
	
	static func get(from full: CubeTransformation) -> Self { full }
	
	func repeatedApplications(to start: Self? = nil) -> UnfoldSequence<Self, (Self?, Bool)> {
		sequence(first: start ?? self) { $0 + self }
	}
	
	func uniqueApplications() -> [Self] {
		repeatedApplications(to: self).prefix { $0 != .zero }
	}
}

extension CubeTransformation.Corners: PartialCornerState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			permutation: one.permutation + two,
			orientation: one.orientation + two
		)
	}
	
	static prefix func - (t: Self) -> Self {
		let inversePerm = -t.permutation
		return .init(
			permutation: inversePerm,
			orientation: -t.orientation.applying(inversePerm)
		)
	}
}

// TODO: unify with corners?
extension CubeTransformation.Edges: PartialEdgeState {
	static let zero = Self()
	
	static func + (one: Self, two: Self) -> Self {
		.init(
			permutation: one.permutation + two,
			orientation: one.orientation + two
		)
	}
	
	static prefix func - (t: Self) -> Self {
		let inversePerm = -t.permutation
		return .init(
			permutation: inversePerm,
			orientation: -t.orientation.applying(inversePerm)
		)
	}
}
