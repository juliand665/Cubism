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
				.builtIn(
					id: "oll look 2 sune",
					name: "Sune",
					configuration: .oll(.cornersOnly(ne: .facingCW, se: .facingCW, nw: .facingCW))
				) {
					"(R U Ri) U (R UU Ri)"
				},
				.builtIn(
					id: "oll look 2 anti-sune",
					name: "Anti-Sune",
					configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCCW, sw: .facingCCW))
				) {
					"(Ri Ui R) Ui (Ri UU R)"
				},
				.builtIn(
					id: "oll look 2 cross",
					name: "Cross",
					configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCW, sw: .facingCCW, nw: .facingCW))
				) {
					"F (R U Ri Ui) (R U Ri Ui) (R U Ri Ui) Fi"
					"y (Ri Ui R) Ui (Ri U R) Ui (Ri UU R)"
					"y R U Ri U R Ui Ri U R UU Ri"
					
				},
				.builtIn(
					id: "oll look 2 pi",
					name: "Pi",
					configuration: .oll(.cornersOnly(ne: .facingCCW, se: .facingCW, sw: .facingCW, nw: .facingCCW))
				) {
					"[f (R U Ri Ui) fi] [F (R U Ri Ui) Fi]"
					"R UU RR Ui RR Ui RR UU R"
				},
				.builtIn(
					id: "oll look 2 headlights",
					name: "Headlights",
					configuration: .oll(.cornersOnly(se: .facingCW, sw: .facingCCW))
				) {
					"(RR D) (Ri UU) (R Di) (Ri UU Ri)"
					"(RR D Ri UU Ri) (RR Di Ri UU Ri)"
					
				},
				.builtIn(
					id: "oll look 2 chameleon",
					name: "Chameleon",
					configuration: .oll(.cornersOnly(sw: .facingCCW, nw: .facingCW))
				) {
					"(r U Ri Ui) (ri F R Fi)"
				},
				.builtIn(
					id: "oll look 2 bowtie",
					name: "Bowtie",
					configuration: .oll(.cornersOnly(se: .facingCW, nw: .facingCCW))
				) {
					"Fi (r U Ri Ui) (ri F R _)"
				},
			])
		]
	)
}
