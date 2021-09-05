import Foundation

extension AlgorithmFolder {
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
}
