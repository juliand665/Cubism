import Foundation

extension AlgorithmFolder {
	static let simplifiedPLL = Self(
		name: "Simplified PLL",
		description: "A small subset of easy PLL algorithms allowing you to solve any configuration in up to 3 applications.",
		sections: [
			.init(name: "corners", algorithms: [
				.tPerm,
				.yPerm,
			]),
			.init(name: "edges", algorithms: [
				.uPermA,
				.uPermB,
				.hPerm,
				.zPerm,
			]),
		]
	)
	
	static let fullPLL = Self(
		name: "Full PLL",
		description: "Permute the pieces in the last layer, keeping orientation intact, using just one algorithm.",
		sections: [
			.init(name: "edges only", algorithms: [
				.uPermB, .uPermA,
				.zPerm,
				.hPerm,
			]),
			.init(name: "corners only", algorithms: [
				.aPermA, .aPermB,
				.ePerm,
			]),
			.init(name: "swap adjacent corners", algorithms: [
				.rPermB, .rPermA,
				.jPermB, .jPermA,
				.tPerm,
				.fPerm,
			]),
			.init(name: "swap opposite corners", algorithms: [
				.vPerm,
				.yPerm,
				.nPermB, .nPermA,
			]),
			.init(name: "double spins", algorithms: [
				.gPermA, .gPermB,
				.gPermD, .gPermC,
			]),
		]
	)
}

extension Algorithm {
	static let aPermA = Self(
		name: "Aa (clockwise)",
		configuration: .pll(.init(
			cornerCycles: [[.nw, .ne, .sw]]
		)),
		variants: [
			"x LL DD Li Ui L DD Li U Li",
		]
	)
	
	static let aPermB = Self(
		name: "Ab (counterclockwise)",
		configuration: .pll(.init(
			cornerCycles: [[.nw, .sw, .se]]
		)),
		variants: [
			"x' LL DD L U Li DD L Ui L",
		]
	)
	
	static let ePerm = Self(
		name: "E",
		configuration: .pll(.init(
			cornerCycles: [[.ne, .se], [.nw, .sw]]
		)),
		variants: [
			"xi (R Ui Ri) D (R U Ri) Di (R U Ri) D (R Ui Ri) Di",
		]
	)
	
	static let fPerm = Self(
		name: "F",
		configuration: .pll(.init(
			edgeCycles: [[.north, .south]],
			cornerCycles: [[.ne, .se]]
		)),
		variants: [
			"Ri Ui Fi (R U Ri Ui) (Ri F) (RR Ui Ri Ui) R U Ri U R",
		]
	)
	
	static let gPermA = Self(
		name: "Ga (corners CW)",
		configuration: .pll(.init(
			edgeCycles: [[.east, .north, .west]],
			cornerCycles: [[.sw, .nw, .ne]]
		)),
		variants: [
			"RR u Ri U Ri Ui R ui RR yi Ri U R",
			"RR u Ri U Ri Ui R ui RR Bi U B",
			"RR U Ri U Ri Ui R Ui RR Ui D Ri U R Di U",
		]
	)
	
	static let gPermB = Self(
		name: "Gb (corners CCW)",
		configuration: .pll(.init(
			edgeCycles: [[.west, .north, .east]],
			cornerCycles: [[.ne, .nw, .sw]]
		)),
		variants: [
			"yi Ri Ui R y RR u Ri U R Ui R ui RR",
			"Fi Ui F RR u Ri U R Ui R ui RR",
			"yi Ri Ui R U Di RR U Ri U R Ui R Ui RR D Ui",
		]
	)
	
	static let gPermC = Self(
		name: "Gc (corners CCW)",
		configuration: .pll(.init(
			edgeCycles: [[.east, .south, .west]],
			cornerCycles: [[.nw, .sw, .se]]
		)),
		variants: [
			"RR ui R Ui R U Ri u RR y R Ui Ri",
			"RR ui R Ui R U Ri u RR B Ui Bi",
			"RR Ui R Ui R U Ri U RR U Di R Ui Ri D Ui",
		]
	)
	
	static let gPermD = Self(
		name: "Gd (corners CW)",
		configuration: .pll(.init(
			edgeCycles: [[.west, .south, .east]],
			cornerCycles: [[.se, .sw, .nw]]
		)),
		variants: [
			"y R U Ri yi RR ui R Ui Ri U Ri u RR",
			"B U Bi RR ui R Ui Ri U Ri u RR",
			"y R U Ri Ui D RR Ui R Ui Ri U Ri U RR Di U",
		]
	)
	
	static let hPerm = Self(
		name: "H",
		configuration: .pll(.init(
			edgeCycles: [[.north, .south], [.east, .west]]
		)),
		variants: [
			"MM U MM UU MM U MM",
		]
	)
	
	static let jPermA = Self(
		name: "Ja",
		configuration: .pll(.init(
			edgeCycles: [[.north, .west]],
			cornerCycles: [[.nw, .ne]]
		)),
		variants: [
			"(Ri U Li) UU (R Ui Ri) UU (R L Ui)",
		]
	)
	
	static let jPermB = Self(
		name: "Jb",
		configuration: .pll(.init(
			edgeCycles: [[.south, .east]],
			cornerCycles: [[.se, .ne]]
		)),
		variants: [
			"(R U Ri Fi) (R U Ri Ui) (Ri F) (RR Ui Ri Ui)",
		]
	)
	
	static let nPermA = Self(
		name: "Na",
		configuration: .pll(.init(
			edgeCycles: [[.north, .south]],
			cornerCycles: [[.nw, .se]]
		)),
		variants: [
			"((L Ui R) UU (Li U Ri)) ((L Ui R) UU (Li U Ri)) U",
			"y R Ui Ri U l U F Ui Ri Fi R Ui R U li U Ri",
		]
	)
	
	static let nPermB = Self(
		name: "Nb",
		configuration: .pll(.init(
			edgeCycles: [[.north, .south]],
			cornerCycles: [[.ne, .sw]]
		)),
		variants: [
			"((Ri U Li) UU (R Ui L)) ((Ri U Li) UU (R Ui L)) Ui",
		]
	)
	
	static let rPermA = Self(
		name: "Ra",
		configuration: .pll(.init(
			edgeCycles: [[.south, .west]],
			cornerCycles: [[.nw, .ne]]
		)),
		variants: [
			"L UU Li UU L Fi Li Ui L U L F LL U",
		]
	)
	
	static let rPermB = Self(
		name: "Rb",
		configuration: .pll(.init(
			edgeCycles: [[.south, .east]],
			cornerCycles: [[.nw, .ne]]
		)),
		variants: [
			"Ri UU R UU (Ri F) (R U Ri Ui) Ri Fi RR Ui",
		]
	)
	
	static let tPerm = Self(
		name: "T",
		configuration: .pll(.init(
			edgeCycles: [[.east, .west]],
			cornerCycles: [[.ne, .se]]
		)),
		variants: [
			"(R U Ri Ui) (Ri F) (RR Ui Ri Ui) (R U Ri Fi)",
		]
	)
	
	static let uPermA = Self(
		name: "Ua (counterclockwise)",
		configuration: .pll(.init(
			edgeCycles: [[.west, .south, .east]]
		)),
		variants: [
			"MM U M UU Mi U MM",
			"FF Ui (L Ri) FF (Li R) Ui FF",
			"[R Ui] [R U] [R U] [R Ui] Ri Ui RR",
		]
	)
	
	static let uPermB = Self(
		name: "Ub (clockwise)",
		configuration: .pll(.init(
			edgeCycles: [[.east, .south, .west]]
		)),
		variants: [
			"MM Ui M UU Mi Ui MM",
			"FF U (L Ri) FF (Li R) U FF",
			"RR U [R U Ri Ui] (Ri Ui) (Ri U Ri)",
		]
	)
	
	static let vPerm = Self(
		name: "V",
		configuration: .pll(.init(
			edgeCycles: [[.north, .east]],
			cornerCycles: [[.nw, .se]]
		)),
		variants: [
			"Ri U Ri di Ri Fi RR Ui Ri U Ri F R F",
		]
	)
	
	static let yPerm = Self(
		name: "Y",
		configuration: .pll(.init(
			edgeCycles: [[.south, .west]],
			cornerCycles: [[.nw, .se]]
		)),
		variants: [
			"F [R Ui Ri Ui] [R U Ri Fi] {[R U Ri Ui] [Ri F R Fi]}",
		]
	)
	
	static let zPerm = Self(
		name: "Z",
		configuration: .pll(.init(
			edgeCycles: [[.north, .west], [.south, .east]]
		)),
		variants: [
			"MM U MM U Mi UU MM UU Mi UU",
			"MM U MM U M UU MM UU M UU",
		]
	)
}
