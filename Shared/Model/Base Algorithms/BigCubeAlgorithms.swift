import Foundation

extension AlgorithmFolder {
	static let bigCubes = Self(
		name: "Big Cubes",
		description: "Algorithms for dealing with big cubes (4x4 and up), especially parity.",
		sections: [
			.init(name: "4x4x4", algorithms: [
				.edgeHalfSwap,
				.ollParity,
				.pllParity,
			]),
			.init(name: "5x5x5", algorithms: [
				.edgeMiddleFlip,
				.edgeEndSwap,
			]),
		]
	)
}

extension Algorithm {
	static let edgeHalfSwap = builtIn(
		id: "edge half swap",
		name: "Edge Half Swap",
		description: "Swaps half of FL and FR."
	) {
		"Dw R Fi U Ri F Dwi"
	}
	
	static let ollParity = builtIn(
		id: "oll parity",
		name: "OLL Parity",
		description: "Flips UF edge."
	) {
		"Rww BB UU Lw UU Rwi UU Rw UU FF Rw FF Lwi BB Rww"
	}
	
	static let pllParity = builtIn(
		id: "pll parity",
		name: "PLL Parity",
		description: "Swaps UF and UB edges."
	) {
		"2RR UU 2RR Uww 2RR 2UU"
	}
}

extension Algorithm {
	static let edgeMiddleFlip = builtIn(
		id: "edge middle flip",
		name: "Edge Middle Flip",
		description: "Flips middle part of UF edge."
	) {
		"Rww BB UU Lw UU Rwi UU Rw UU FF Rw FF Lwi BB Rww"
		"Rw UU Rw UU Rwi UU Rw UU Lwi UU Rw UU Rwi UU xi Rwi UU Rwi UU Mi"
	}
	
	static let edgeEndSwap = builtIn(
		id: "edge end swap",
		name: "Edge End Swap",
		description: "Swaps right ends of UF and UB edges."
	) {
		"Lwi UU Lwi UU FF Lwi FF Rw UU Rwi UU Lww"
	}
}
