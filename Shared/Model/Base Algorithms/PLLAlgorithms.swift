import Foundation

extension AlgorithmFolder {
	static let simplifiedPLL = Self(
		name: "2-Look PLL",
		description: "A small subset of easy PLL algorithms allowing you to solve any configuration in up to 2 applications. (Start here!)",
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
				.gPermC, .gPermD,
			]),
		]
	)
}

extension Algorithm {
	static let aPermA = builtIn(
		id: "a perm a",
		name: "Aa (clockwise)",
		configuration: .computedPLL
	) {
		"x (Ri U Ri) DD (R Ui Ri) DD RR xi"
		"li U Ri DD R Ui Ri DD RR"
		"yi x LL DD Li Ui L DD Li U Li"
	}
	
	static let aPermB = builtIn(
		id: "a perm b",
		name: "Ab (counterclockwise)",
		configuration: .computedPLL
	) {
		"xi (R Ui R) DD (Ri U R) DD RR x"
		"l Ui R DD Ri U R DD RR"
		"y xi LL DD L U Li DD L Ui L"
	}
	
	static let ePerm = builtIn(
		id: "e perm",
		name: "E",
		configuration: .computedPLL
	) {
		"xi (R Ui Ri) D (R U Ri) Di (R U Ri) D (R Ui Ri) Di"
		"xi (R Ui Ri) D (R U Ri) uu (Ri U R) D (Ri Ui R)"
		"xi Li U L Di Li Ui L D Li Ui L Di Li U L D"
	}
	
	static let fPerm = builtIn(
		id: "f perm",
		name: "F",
		configuration: .computedPLL
	) {
		"Ri Ui Fi (R U Ri Ui) (Ri F) (RR Ui Ri Ui) R U Ri U R"
		"y (Ri UU Ri di) Ri Fi (RR Ui Ri U) (Ri F R Ui F)"
	}
	
	static let gPermA = builtIn(
		id: "g perm a",
		name: "Ga (corners CW)",
		configuration: .computedPLL
	) {
		"RR u Ri U Ri Ui R ui RR yi Ri U R"
		"RR u Ri U Ri Ui R ui RR Fi U F"
		"RR U Ri U Ri Ui R Ui RR Ui D Ri U R Di U"
	}
	
	static let gPermB = builtIn(
		id: "g perm b",
		name: "Gb (corners CCW)",
		configuration: .computedPLL
	) {
		"yi Ri Ui R y RR u Ri U R Ui R ui RR"
		"Fi Ui F RR u Ri U R Ui R ui RR"
		"yi Ri Ui R U Di RR U Ri U R Ui R Ui RR D Ui"
	}
	
	static let gPermC = builtIn(
		id: "g perm c",
		name: "Gc (corners CCW)",
		configuration: .computedPLL
	) {
		"RR ui R Ui R U Ri u RR y R Ui Ri"
		"RR ui R Ui R U Ri u RR B Ui Bi"
		"RR Ui R Ui R U Ri U RR U Di R Ui Ri D Ui"
	}
	
	static let gPermD = builtIn(
		id: "g perm d",
		name: "Gd (corners CW)",
		configuration: .computedPLL
	) {
		"y R U Ri yi RR ui R Ui Ri U Ri u RR"
		"B U Bi RR ui R Ui Ri U Ri u RR"
		"y R U Ri Ui D RR Ui R Ui Ri U Ri U RR Di U"
	}
	
	static let hPerm = builtIn(
		id: "h perm",
		name: "H",
		configuration: .computedPLL
	) {
		"MM U MM UU MM U MM"
	}
	
	static let jPermA = builtIn(
		id: "j perm a",
		name: "Ja",
		configuration: .computedPLL
	) {
		"(Ri U Li) UU (R Ui Ri) UU (R L Ui)"
		"y li Ri F R Fi R UU ri U r UU"
		"y (ll U l Fi) R UU (ri U r) UU"
	}
	
	static let jPermB = builtIn(
		id: "j perm b",
		name: "Jb",
		configuration: .computedPLL
	) {
		"(R U Ri Fi) (R U Ri Ui) (Ri F) (RR Ui Ri Ui)"
	}
	
	static let nPermA = builtIn(
		id: "n perm a",
		name: "Na",
		configuration: .computedPLL
	) {
		"((L Ui R) UU (Li U Ri)) ((L Ui R) UU (Li U Ri)) U"
		"y R Ui Ri U l U F Ui Ri Fi R Ui R U li U Ri"
		"y R U Ri U (R U Ri Fi) (R U Ri Ui) (Ri F) RR Ui Ri UU R Ui Ri"
	}
	
	static let nPermB = builtIn(
		id: "n perm b",
		name: "Nb",
		configuration: .computedPLL
	) {
		"((Ri U Li) UU (R Ui L)) ((Ri U Li) UU (R Ui L)) Ui"
		"y Ri U R Ui Ri Fi Ui F R U Ri F Ri Fi R Ui R"
	}
	
	static let rPermA = builtIn(
		id: "r perm a",
		name: "Ra",
		configuration: .computedPLL
	) {
		"L UU Li UU L Fi Li Ui L U L F LL U"
		"y R Ui Ri Ui R U R D Ri Ui R Di Ri UU Ri Ui"
	}
	
	static let rPermB = builtIn(
		id: "r perm b",
		name: "Rb",
		configuration: .computedPLL
	) {
		"Ri UU R UU (Ri F) (R U Ri Ui) Ri Fi RR Ui"
		"y RR F R U R Ui Ri Fi R UU Ri UU R U"
	}
	
	static let tPerm = builtIn(
		id: "t perm",
		name: "T",
		configuration: .computedPLL
	) {
		"(R U Ri Ui) (Ri F) (RR Ui Ri Ui) (R U Ri Fi)"
	}
	
	static let uPermA = builtIn(
		id: "u perm a",
		name: "Ua (counterclockwise)",
		configuration: .computedPLL
	) {
		"MM U M UU Mi U MM"
		"FF Ui (L Ri) FF (Li R) Ui FF"
		"[R Ui] [R U] [R U] [R Ui] Ri Ui RR"
	}
	
	static let uPermB = builtIn(
		id: "u perm b",
		name: "Ub (clockwise)",
		configuration: .computedPLL
	) {
		"MM Ui M UU Mi Ui MM"
		"FF U (L Ri) FF (Li R) U FF"
		"RR U [R U Ri Ui] (Ri Ui) (Ri U Ri)"
	}
	
	static let vPerm = builtIn(
		id: "v perm",
		name: "V",
		configuration: .computedPLL
	) {
		"Ri U Ri di Ri Fi RR Ui Ri U Ri F R F"
		"Ri U Ri Ui y Ri Fi RR Ui Ri U Ri F R F"
		"y R Ui (R U Ri) D R Di R (Ui D) RR U RR Di RR"
		"Ri U R Ui Ri fi Ui R UU Ri Ui R Ui Ri f R"
	}
	
	static let yPerm = builtIn(
		id: "y perm",
		name: "Y",
		configuration: .computedPLL
	) {
		"F [R Ui Ri Ui] [R U Ri Fi] {[R U Ri Ui] [Ri F R Fi]}"
	}
	
	static let zPerm = builtIn(
		id: "z perm",
		name: "Z",
		configuration: .computedPLL
	) {
		"MM U MM U Mi UU MM UU Mi UU"
		"MM U MM U M UU MM UU M UU"
	}
}
