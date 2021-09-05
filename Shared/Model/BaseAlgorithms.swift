import Foundation

extension AlgorithmCollection {
	static let base = Self(folders: [
		.twoLookOLL,
		.minimalPLL,
		.fullPLL,
		.miscellaneous,
	])
}

extension AlgorithmCollection.Folder {
	static let twoLookOLL = Self(
		name: "2-Look OLL",
		description: "Orient the edges in the last layer to all face up.",
		algorithms: [
			// edges
			Algorithm(
				name: "Opposite",
				configuration: .oll(.edgesOnly(correctEdges: [.east, .west])),
				variants: ["F (R U Ri Ui) Fi"]
			),
			Algorithm(
				name: "Adjacent",
				configuration: .oll(.edgesOnly(correctEdges: [.east, .south])),
				variants: ["f (R U Ri Ui) fi"]
			),
			Algorithm(
				name: "No Edges",
				configuration: .oll(.edgesOnly(correctEdges: [])),
				variants: ["[F (R U Ri Ui) Fi] [f (R U Ri Ui) fi]"]
			),
			// corners
			Algorithm(
				name: "Sune",
				configuration: .oll(.cornersOnly(ne: .facingCW, se: .facingCW, nw: .facingCW)),
				variants: ["(R U Ri) U (R UU Ri)"]
			),
			Algorithm(
				name: "Anti-Sune",
				configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCCW, sw: .facingCCW)),
				variants: ["(Ri Ui R) Ui (Ri UU R)"]
			),
			Algorithm(
				name: "Symmetrical Cross",
				configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCW, sw: .facingCW, nw: .facingCCW)),
				variants: [
					"F (R U Ri Ui) (R U Ri Ui) (R U Ri Ui) Fi",
					"y (Ri Ui R) Ui (Ri U R) Ui (Ri UU R)",
					"y R U Ri U R Ui Ri U R UU Ri",
				]
			),
			Algorithm(
				name: "Asymmetrical Cross",
				configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCW, sw: .facingCW, nw: .facingCCW)),
				variants: [
					"[f (R U Ri Ui) fi] [F (R U Ri Ui) Fi]",
					"R UU RR Ui RR Ui RR UU R",
				]
			),
			Algorithm(
				name: "Headlights",
				configuration: .oll(.cornersOnly(se: .facingCW, sw: .facingCCW)),
				variants: [
					"(RR D) (Ri UU) (R Di) (Ri UU Ri)",
					"(RR D Ri UU Ri) (RR Di Ri UU Ri)",
				]
			),
			Algorithm(
				name: "Frog",
				configuration: .oll(.cornersOnly(sw: .facingCCW, nw: .facingCW)),
				variants: ["(r U Ri Ui) (ri F R Fi)"]
			),
			Algorithm(
				name: "Diagonal",
				configuration: .oll(.cornersOnly(se: .facingCW, nw: .facingCCW)),
				variants: ["Fi (r U Ri Ui) (ri F R _)"]
			),
		]
	)
	
	static let minimalPLL = Self(
		name: "Minimal PLL",
		description: "A small subset of easy PLL algorithms allowing you to solve any configuration in up to 3 applications.",
		algorithms: [
			.tPerm,
			.yPerm,
			.uPermCW,
			.uPermCCW,
			.hPerm,
			.zPerm,
		]
	)
	
	static let fullPLL = Self(
		name: "Full PLL",
		description: "Permute the pieces in the last layer, keeping orientation intact, using just one algorithm.",
		algorithms: [
			.tPerm,
			.yPerm,
			.uPermCW,
			.uPermCCW,
			.hPerm,
			.zPerm,
			.ePerm,
			// TODO: others
		]
	)
	
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
	static let tPerm = Self(
		name: "T",
		configuration: .pll(.init(
			edgeCycles: [[.east, .west]],
			cornerCycles: [[.ne, .se]]
		)),
		variants: ["[R U Ri Ui] [Ri F] R[R Ui Ri Ui] [R U Ri Fi]"]
	)
	
	static let yPerm = Self(
		name: "Y",
		configuration: .pll(.init(
			edgeCycles: [[.south, .west]],
			cornerCycles: [[.nw, .se]]
		)),
		variants: ["F [R Ui Ri Ui] [R U Ri Fi] {[R U Ri Ui] [Ri F R Fi]}"]
	)
	
	static let uPermCW = Self(
		name: "U (clockwise)",
		configuration: .pll(.init(
			edgeCycles: [[.east, .south, .west]]
		)),
		variants: [
			"MM Ui M UU Mi Ui MM",
			"FF U (L Ri) FF (Li R) U FF",
			"RR U [R U Ri Ui] (Ri Ui) (Ri U Ri)",
		]
	)
	
	static let uPermCCW = Self(
		name: "U (counterclockwise)",
		configuration: .pll(.init(
			edgeCycles: [[.west, .south, .east]]
		)),
		variants: [
			"MM U M UU Mi U MM",
			"FF Ui (L Ri) FF (Li R) Ui FF",
			"[R Ui] [R U] [R U] [R Ui] Ri Ui RR",
		]
	)
	
	static let hPerm = Self(
		name: "H",
		configuration: .pll(.init(
			edgeCycles: [[.north, .south], [.east, .west]]
		)),
		variants: ["MM U MM UU MM U MM"]
	)
	
	static let zPerm = Self(
		name: "Z",
		configuration: .pll(.init(
			edgeCycles: [[.north, .west], [.south, .east]]
		)),
		variants: ["MM U MM U Mi UU MM UU Mi UU"]
	)
	
	static let ePerm = Self(
		name: "E",
		configuration: .pll(.init(
			cornerCycles: [[.ne, .se], [.nw, .sw]]
		)),
		variants: ["xi (R Ui Ri) D (R U Ri) Di (R U Ri) D (R Ui Ri) Di"]
	)
	
	static let cubeInACube = Self(
		name: "Cube in a Cube (CCW)",
		variants: ["(F L F) (Ui R U) FF LL (Ui Li B Di Bi) LL U"]
	)
	
	static let cubeletInACube = Self(
		name: "Cubelet in a Cube (CW)",
		variants: ["BB (Ri D R Di Ri D R) U (Ri Di R D Ri Di R) Ui BB"]
	)
}
