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
	static let cubeInACube = builtIn(
		id: "cube in a cube ccw",
		name: "Cube in a Cube (CCW)"
	) {
		"(F L F) (Ui R U) FF LL (Ui Li B Di Bi) LL U"
	}
	
	static let cubeletInACube = builtIn(
		id: "cubelet in a cube cw",
		name: "Cubelet in a Cube (CW)"
	) {
		"BB (Ri D R Di Ri D R) U (Ri Di R D Ri Di R) Ui BB"
	}
}

extension Algorithm {
	static let centerRotation90UL = builtIn(
		id: "center rotation 90 ul",
		name: "Rotate 2 Centers 90°",
		description: "Rotates U center clockwise, L center CCW."
	) {
		"U M E Mi Ui M Ei Mi"
	}
	
	static let centerRotation90UF = builtIn(
		id: "center rotation 90 uf",
		name: "Rotate 2 Centers 90°",
		description: "Rotates U CW, F CCW."
	) {
		"(Mi Ui M U) (Mi Ui M U) (Mi Ui M U) (Mi Ui M U) (Mi Ui M U)"
	}
	
	static let centerRotation180 = builtIn(
		id: "center rotation 180 u",
		name: "Rotate Center 180°",
		description: "Rotates U center 180°."
	) {
		"(U R L UU Li Ri) (U R L UU Li Ri)"
		"(R U Ri U) (R U Ri U) (R U Ri U) (R U Ri U) (R U Ri U)"
	}
}
