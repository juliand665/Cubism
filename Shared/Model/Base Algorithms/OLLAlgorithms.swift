import Foundation

extension AlgorithmFolder {
	static let twoLookOLL = Self(
		name: "2-Look OLL",
		description: "Orient the edges in the last layer to all face up.",
		sections: [
			.init(name: "edges", algorithms: [
				.builtIn(
					id: "oll look 1 opposite",
					name: "Opposite",
					configuration: .oll(.edgesOnly(correctEdges: [.east, .west]))
				) {
					"F (R U Ri Ui) Fi"
				},
				.builtIn(
					id: "oll look 1 adjacent",
					name: "Adjacent",
					configuration: .oll(.edgesOnly(correctEdges: [.east, .south]))
				) {
					"f (R U Ri Ui) fi"
				},
				.builtIn(
					id: "oll look 1 no edges",
					name: "No Edges",
					configuration: .oll(.edgesOnly(correctEdges: []))
				) {
					"[F (R U Ri Ui) Fi] [f (R U Ri Ui) fi]"
				},
			]),
			.init(name: "corners", algorithms: [
				.sune,
				.antiSune,
				.cross,
				.pi,
				.headlights,
				.chameleon,
				.bowtie,
			])
		]
	)
}

extension Algorithm {
	static let sune = builtIn(
		id: "sune",
		name: "Sune",
		configuration: .oll(.cornersOnly(ne: .twistedCCW, se: .twistedCCW, nw: .twistedCCW))
	) {
		"(R U Ri) U (R UU Ri)"
	}
	
	static let antiSune = builtIn(
		id: "anti-sune",
		name: "Anti-Sune",
		configuration: .oll(.cornersOnly(ne: .twistedCW, se: .twistedCW, sw: .twistedCW))
	) {
		"(Ri Ui R) Ui (Ri UU R)"
	}
	
	static let cross = builtIn(
		id: "cross",
		name: "Cross",
		configuration: .oll(.cornersOnly(ne: .twistedCW, se: .twistedCCW, sw: .twistedCW, nw: .twistedCCW))
	) {
		"F (R U Ri Ui) (R U Ri Ui) (R U Ri Ui) Fi"
		"y (Ri Ui R) Ui (Ri U R) Ui (Ri UU R)"
		"y R U Ri U R Ui Ri U R UU Ri"
	}
	
	static let pi = builtIn(
		id: "pi",
		name: "Pi",
		configuration: .oll(.cornersOnly(ne: .twistedCW, se: .twistedCCW, sw: .twistedCCW, nw: .twistedCW))
	) {
		"[f (R U Ri Ui) fi] [F (R U Ri Ui) Fi]"
		"R UU RR Ui RR Ui RR UU R"
	}
	
	static let headlights = builtIn(
		id: "headlights",
		name: "Headlights",
		configuration: .oll(.cornersOnly(se: .twistedCCW, sw: .twistedCW))
	) {
		"(RR D) (Ri UU) (R Di) (Ri UU Ri)"
		"(RR D Ri UU Ri) (RR Di Ri UU Ri)"
	}
	
	static let chameleon = builtIn(
		id: "chameleon",
		name: "Chameleon",
		configuration: .oll(.cornersOnly(sw: .twistedCW, nw: .twistedCCW))
	) {
		"(r U Ri Ui) (ri F R Fi)"
	}
	
	static let bowtie = builtIn(
		id: "bowtie",
		name: "Bowtie",
		configuration: .oll(.cornersOnly(se: .twistedCCW, nw: .twistedCW))
	) {
		"Fi (r U Ri Ui) (ri F R _)"
	}
}
