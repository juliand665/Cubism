import HandyOperators

extension PiecePermutation {
	static func random() -> Self {
		.init(array: Piece.allCases.shuffled())
	}
}

extension PieceOrientation {
	static func random() -> Self {
		.init(Coord.allValues.randomElement()!)
	}
}

extension CubeTransformation {
	static func random() -> Self {
		let cornerPerm = CornerPermutation.random()
		let edgePerm = EdgePermutation.random() <- { edgePerm in
			let hasParity = cornerPerm.permutationParity != edgePerm.permutationParity
			if hasParity {
				swap(&edgePerm.fl, &edgePerm.fr)
			}
		}
		return .init(
			cornerPermutation: cornerPerm,
			cornerOrientation: .random(),
			edgePermutation: edgePerm,
			edgeOrientation: .random()
		)
	}
}
