import Foundation

extension AlgorithmFolder {
	static let miscellaneous = Self(
		name: "Miscellaneous",
		description: "Some fun algorithms that don't fit into the other categories.",
		algorithms: [
			.cubeInACube,
			.cubeletInACube,
		]
	)
}

extension Algorithm {
	static let cubeInACube = Self(
		name: "Cube in a Cube (CCW)",
		variants: ["(F L F) (Ui R U) FF LL (Ui Li B Di Bi) LL U"]
	)
	
	static let cubeletInACube = Self(
		name: "Cubelet in a Cube (CW)",
		variants: ["BB (Ri D R Di Ri D R) U (Ri Di R D Ri Di R) Ui BB"]
	)
}
