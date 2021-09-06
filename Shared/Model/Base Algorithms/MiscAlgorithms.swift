import Foundation

extension AlgorithmFolder {
	static let miscellaneous = Self(
		name: "Miscellaneous",
		description: "Some fun algorithms that don't fit into the other categories.",
		sections: [
			.init(name: "cube in a cube", algorithms: [
				.cubeInACube,
				.cubeletInACube,
			]),
			.init(name: "center rotations", algorithms: [
				.centerRotation90UL,
				.centerRotation90UF,
				.centerRotation180,
			]),
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

extension Algorithm {
	static let centerRotation90UL = Self(
		name: "Rotate 2 Centers 90° (U CW, L CCW)",
		variants: ["U M E Mi Ui M Ei Mi"]
	)
	
	static let centerRotation90UF = Self(
		name: "Rotate 2 Centers 90° (U CW, F CCW)",
		variants: [
			"(Mi Ui M U) (Mi Ui M U) (Mi Ui M U) (Mi Ui M U) (Mi Ui M U)",
		]
	)
	
	static let centerRotation180 = Self(
		name: "Rotate Center 180° (U face)",
		variants: [
			"(U R L UU Li Ri) (U R L UU Li Ri)",
			"(R U Ri U) (R U Ri U) (R U Ri U) (R U Ri U) (R U Ri U)",
		]
	)
}
