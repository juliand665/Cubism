import Foundation
import ArrayBuilder

extension AlgorithmFolder {
	static let twoLookOLL = Self(
		name: "2-Look OLL",
		description: "Orient the pieces in the last layer with just 10 algorithms applied at most twice.",
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
				.FourEdgeOLL.cross,
				.FourEdgeOLL.pi,
				.FourEdgeOLL.sune,
				.FourEdgeOLL.antiSune,
				.FourEdgeOLL.headlights,
				.FourEdgeOLL.chameleon,
				.FourEdgeOLL.bowtie,
			]),
		]
	)
	
	static let fullOLL = Self(
		name: "Full OLL",
		description: "All 57 OLL algorithms, allowing you to solve any orientation with a single look.",
		sections: [
			.init(name: "No Edges Correct", algorithms: [
				.ZeroEdgeOLL.cross,
				.ZeroEdgeOLL.pi,
				.ZeroEdgeOLL.sune,
				.ZeroEdgeOLL.antiSune,
				.ZeroEdgeOLL.headlights,
				.ZeroEdgeOLL.chameleon,
				.ZeroEdgeOLL.bowtie,
				.ZeroEdgeOLL.x,
			]),
			.init(name: "Opposite Edges Correct", algorithms: [
				.OppositeEdgeOLL.crossA,
				.OppositeEdgeOLL.crossB,
				.OppositeEdgeOLL.piA,
				.OppositeEdgeOLL.piB,
				.OppositeEdgeOLL.suneA,
				.OppositeEdgeOLL.suneB,
				.OppositeEdgeOLL.antiSuneA,
				.OppositeEdgeOLL.antiSuneB,
				.OppositeEdgeOLL.headlightsA,
				.OppositeEdgeOLL.headlightsB,
				.OppositeEdgeOLL.chameleonA,
				.OppositeEdgeOLL.chameleonB,
				.OppositeEdgeOLL.bowtieA,
				.OppositeEdgeOLL.bowtieB,
				.OppositeEdgeOLL.x,
			]),
			.init(name: "Adjacent Edges Correct", algorithms: [
				.AdjacentEdgeOLL.crossA,
				.AdjacentEdgeOLL.crossB,
				.AdjacentEdgeOLL.piA,
				.AdjacentEdgeOLL.piB,
				.AdjacentEdgeOLL.piC,
				.AdjacentEdgeOLL.piD,
				.AdjacentEdgeOLL.suneA,
				.AdjacentEdgeOLL.suneB,
				.AdjacentEdgeOLL.suneC,
				.AdjacentEdgeOLL.suneD,
				.AdjacentEdgeOLL.antiSuneA,
				.AdjacentEdgeOLL.antiSuneB,
				.AdjacentEdgeOLL.antiSuneC,
				.AdjacentEdgeOLL.antiSuneD,
				.AdjacentEdgeOLL.headlightsA,
				.AdjacentEdgeOLL.headlightsB,
				.AdjacentEdgeOLL.headlightsC,
				.AdjacentEdgeOLL.headlightsD,
				.AdjacentEdgeOLL.chameleonA,
				.AdjacentEdgeOLL.chameleonB,
				.AdjacentEdgeOLL.chameleonC,
				.AdjacentEdgeOLL.chameleonD,
				.AdjacentEdgeOLL.bowtieA,
				.AdjacentEdgeOLL.bowtieB,
				.AdjacentEdgeOLL.bowtieC,
				.AdjacentEdgeOLL.bowtieD,
				.AdjacentEdgeOLL.x,
			]),
			.init(name: "All Edges Correct", algorithms: [
				.FourEdgeOLL.cross,
				.FourEdgeOLL.pi,
				.FourEdgeOLL.sune,
				.FourEdgeOLL.antiSune,
				.FourEdgeOLL.headlights,
				.FourEdgeOLL.chameleon,
				.FourEdgeOLL.bowtie,
			]),
		]
	)
}

extension Algorithm {
	enum ZeroEdgeOLL {
		static let cross = builtInOLL(number: 1, name: "0-Edge Cross") {
			"R UU (RR F R Fi) UU (Ri F R Fi)"
			"R UU Ri (Ri F R Fi) UU (Ri F R Fi)"
		}
		
		static let pi = builtInOLL(number: 2, name: "0-Edge Pi") {
			"F (R U Ri Ui) Fi f (R U Ri Ui) fi"
			"F (R U Ri Ui) S (R U Ri Ui) fi"
		}
		
		static let sune = builtInOLL(number: 3, name: "0-Edge Sune") {
			"f (R U Ri Ui) fi Ui F (R U Ri Ui) Fi"
			"y ri R U Ri FF R U Li U L Mi"
			"y M R U Ri U r UU ri U Mi"
		}
		
		static let antiSune = builtInOLL(number: 4, name: "0-Edge Anti-Sune") {
			"f (R U Ri Ui) fi U F (R U Ri Ui) Fi"
			"y l Li Ui L FF Li Ui R Ui Ri Mi"
		}
		
		static let headlights = builtInOLL(number: 18, name: "0-Edge Headlights") {
			"R UU RR F R Fi UU r Ri U R Ui ri"
			"yi (r U Ri U R UU ri) (ri Ui R Ui Ri UU r)"
		}
		
		static let chameleon = builtInOLL(number: 19, name: "0-Edge Chameleon") {
			"M U (R U Ri Ui) r (RR F R Fi)"
			"(ri UU R U Ri U r) (r UU Ri Ui R Ui ri)"
		}
		
		static let bowtie = builtInOLL(number: 17, name: "0-Edge Bowtie") {
			"R U Ri U (Ri F R Fi) UU (Ri F R Fi)"
			"(R U Ri Ui) UU (Ri F R Fi) UU (Ri F R Fi)"
		}
		
		static let x = builtInOLL(number: 20, name: "0-Edge X") {
			"M U (R U Ri Ui) rr RR U R Ui ri"
			"Mi U Mi U Mi U Mi Ui Mi U Mi U Mi U Mi"
		}
	}
	
	enum OppositeEdgeOLL {
		static let crossA = builtInOLL(number: 55, name: "Opposite-Edge Cross A") {
			"r UU Ri Ui RR ri U Ri Ui r Ui ri"
		}
		
		static let crossB = builtInOLL(number: 56, name: "Opposite-Edge Cross B") {
			"r U ri U R Ui Mi Ri U R UU ri"
		}
		
		static let piA = builtInOLL(number: 51, name: "Opposite-Edge Pi A") {
			"f (R U Ri Ui) (R U Ri Ui) fi"
			"yy F (U R Ui Ri) (U R Ui Ri) Fi"
		}
		
		static let piB = builtInOLL(number: 52, name: "Opposite-Edge Pi B") {
			"Ri Ui R Ui Ri d Ri U R B"
		}
		
		static let suneA = builtInOLL(number: 13, name: "Opposite-Edge Sune A") {
			"L Fi Li Ui L F Li Fi U F"
			"F U R Ui RR Fi R U R Ui Ri"
		}
		
		static let suneB = builtInOLL(number: 15, name: "Opposite-Edge Sune B") {
			"li Ui l (Li Ui L U) li U l"
			"yy Li Bi L (Ri Ui R U) Li B L"
		}
		
		static let antiSuneA = builtInOLL(number: 14, name: "Opposite-Edge Anti-Sune A") {
			"Ri F R U Ri Fi R F Ui Fi"
		}
		
		static let antiSuneB = builtInOLL(number: 16, name: "Opposite-Edge Anti-Sune B") {
			"r U ri (R U Ri Ui) r Ui ri"
			"yy R B Ri (L U Li Ui) R Bi Ri"
		}
		
		static let headlightsA = builtInOLL(number: 45, name: "Opposite-Edge Headlights A") {
			"F (R U Ri Ui) Fi"
		}
		
		static let headlightsB = builtInOLL(number: 46, name: "Opposite-Edge Headlights B") {
			"Ri Ui (Ri F R Fi) U R"
			"R U R Bi Ri B Ui Ri"
		}
		
		static let chameleonA = builtInOLL(number: 33, name: "Opposite-Edge Chameleon A") {
			"(R U Ri Ui) (Ri F R Fi)"
			"(Ri Ui R U) l Ui li B"
		}
		
		static let chameleonB = builtInOLL(number: 34, name: "Opposite-Edge Chameleon B") {
			"R U Ri di Ri Fi r U ri R"
			"yy F R U Ri Ui Ri Fi r U R Ui ri"
		}
		
		static let bowtieA = builtInOLL(number: 39, name: "Opposite-Edge Bowtie A") {
			"L Fi Li Ui L U F Ui Li"
			"yy R Bi Ri Ui R U B Ui Ri"
		}
		
		static let bowtieB = builtInOLL(number: 40, name: "Opposite-Edge Bowtie B") {
			"Ri F R U Ri Ui Fi U R"
			"yy Li B L U Li Ui Bi U L"
		}
		
		static let x = builtInOLL(number: 57, name: "Opposite-Edge X") {
			"R U Ri Ui r Ri U R Ui ri"
			"R U Ri Ui Mi U R Ui ri"
			"Mi U Mi U Mi U Mi UU Mi U Mi U Mi U Mi"
		}
	}
	
	enum AdjacentEdgeOLL {
		static let crossA = builtInOLL(number: 53, name: "Adjacent-Edge Cross A") {
			"ri Ui R Ui Ri U R Ui Ri UU r"
		}
		
		static let crossB = builtInOLL(number: 54, name: "Adjacent-Edge Cross B") {
			"r U Ri U R Ui Ri U R UU ri"
		}
		
		static let piA = builtInOLL(number: 47, name: "Adjacent-Edge Pi A") {
			"Fi Li Ui L U Li Ui L U F"
			"Ri Ui x Ri U R Ui Ri U R Ui xi U R"
			"yy ri Fi Li U L Ui Li U L Ui F r"
		}
		
		static let piB = builtInOLL(number: 48, name: "Adjacent-Edge Pi B") {
			"F R U Ri Ui R U Ri Ui Fi"
		}
		
		static let piC = builtInOLL(number: 49, name: "Adjacent-Edge Pi C") {
			"R Bi RR F RR B RR Fi R"
		}
		
		static let piD = builtInOLL(number: 50, name: "Adjacent-Edge Pi D") {
			"Li B LL Fi LL Bi LL F Li"
			"ri U rr Ui rr Ui rr U ri"
		}
		
		static let suneA = builtInOLL(number: 5, name: "Adjacent-Edge Sune A") {
			"ri UU R U Ri U r"
			"yy li UU L U Li U l"
		}
		
		static let suneB = builtInOLL(number: 7, name: "Adjacent-Edge Sune B") {
			"r U Ri U R UU ri"
		}
		
		static let suneC = builtInOLL(number: 10, name: "Adjacent-Edge Sune C") {
			"Mi (Ri UU R U Ri U R) U M"
			"yi R U Ri U (Ri F R Fi) R UU Ri"
		}
		
		static let suneD = builtInOLL(number: 11, name: "Adjacent-Edge Sune D") {
			"M (R U Ri U R UU Ri) U Mi"
			"yy r U Ri U (Ri F R Fi) R UU ri"
		}
		
		static let antiSuneA = builtInOLL(number: 6, name: "Adjacent-Edge Anti-Sune A") {
			"r UU Ri Ui R Ui ri"
			"yy R BB y Bi Ri B Ri Fi"
		}
		
		static let antiSuneB = builtInOLL(number: 8, name: "Adjacent-Edge Anti-Sune B") {
			"ri Ui R Ui Ri UU r"
		}
		
		static let antiSuneC = builtInOLL(number: 9, name: "Adjacent-Edge Anti-Sune C") {
			"M (R UU Ri Ui R Ui Ri) Ui Mi"
			"y (R U Ri Ui) Ri F RR U Ri Ui Fi"
			"y (R U Ri Ui) (Ri F R Fi) F (R U Ri Ui) Fi"
		}
		
		static let antiSuneD = builtInOLL(number: 12, name: "Adjacent-Edge Anti-Sune D") {
			"Mi (Ri Ui R Ui Ri UU R) Ui M"
			"y (F R U Ri Ui Fi) y (F R U Ri Ui Fi)"
			"y (F R U Ri Ui Fi) U (F R U Ri Ui Fi)"
		}
		
		static let headlightsA = builtInOLL(number: 41, name: "Adjacent-Edge Headlights A") {
			"(R U Ri U R UU Ri) (F R U Ri Ui Fi)"
		}
		
		static let headlightsB = builtInOLL(number: 42, name: "Adjacent-Edge Headlights B") {
			"(Ri Ui R Ui Ri UU R) (F R U Ri Ui Fi)"
			"y (Ri F R Fi) (Ri F R Fi) (R U Ri Ui) R U Ri"
		}
		
		static let headlightsC = builtInOLL(number: 43, name: "Adjacent-Edge Headlights C") {
			"Fi Ui Li U L F"
			"yy fi Li Ui L U f"
		}
		
		static let headlightsD = builtInOLL(number: 44, name: "Adjacent-Edge Headlights D") {
			"f R U Ri Ui fi"
			"yy F U R Ui Ri Fi"
		}
		
		static let chameleonA = builtInOLL(number: 29, name: "Adjacent-Edge Chameleon A") {
			"Ri r Ui ri F R UU LL B L Bi L"
			"y RR Ui R F Ri U RR Ui Ri Fi R" // "the connie oll"
		}
		
		static let chameleonB = builtInOLL(number: 30, name: "Adjacent-Edge Chameleon B") {
			"r Ri U R Ui ri UU RR Bi Ri B Ri"
			"y RR U Ri Bi R Ui RR U R B Ri"
		}
		
		static let chameleonC = builtInOLL(number: 31, name: "Adjacent-Edge Chameleon C") {
			"Si Li Ui L U L Fi Li f"
			"Li Ui B U L Ui Li Bi L"
			"yy Ri Ui F U R Ui Ri Fi R"
		}
		
		static let chameleonD = builtInOLL(number: 32, name: "Adjacent-Edge Chameleon D") {
			"S R U Ri Ui Ri F R fi"
			"R U Bi Ui Ri U R B Ri"
		}
		
		static let bowtieA = builtInOLL(number: 35, name: "Adjacent-Edge Bowtie A") {
			"R UU RR F R Fi R UU Ri"
			"R UU Ri (Ri F R Fi) R UU Ri"
		}
		
		static let bowtieB = builtInOLL(number: 36, name: "Adjacent-Edge Bowtie B") {
			"Ri Ui R Ui Ri U R U R Bi Ri B"
			"yy Li Ui L Ui Li U L U L Fi Li F"
		}
		
		static let bowtieC = builtInOLL(number: 37, name: "Adjacent-Edge Bowtie C") {
			"F R Ui Ri Ui R U Ri Fi"
		}
		
		static let bowtieD = builtInOLL(number: 38, name: "Adjacent-Edge Bowtie D") {
			"R U Ri U R Ui Ri Ui (Ri F R Fi)"
			"yy L U Li U L Ui Li Ui Li B L Bi"
		}
		
		static let x = builtInOLL(number: 28, name: "Adjacent-Edge X") {
			"r U Ri Ui R ri U R Ui Ri"
			"yy Mi U M UU Mi U M"
		}
	}
	
	enum FourEdgeOLL {
		static let cross = builtInOLL(number: 21, name: "Cross") {
			"F (R U Ri Ui) (R U Ri Ui) (R U Ri Ui) Fi"
			"y (Ri Ui R) Ui (Ri U R) Ui (Ri UU R)"
			"y R U Ri U R Ui Ri U R UU Ri"
		}
		
		static let pi = builtInOLL(number: 22, name: "Pi") {
			"[f (R U Ri Ui) fi] [F (R U Ri Ui) Fi]"
			"R UU RR Ui RR Ui RR UU R"
		}
		
		static let sune = builtInOLL(number: 27, name: "Sune") {
			"(R U Ri) U (R UU Ri)"
		}
		
		static let antiSune = builtInOLL(number: 26, name: "Anti-Sune") {
			"(Ri Ui R) Ui (Ri UU R)"
		}
		
		static let headlights = builtInOLL(number: 23, name: "Headlights") {
			"(RR D) (Ri UU) (R Di) (Ri UU Ri)"
			"(RR D Ri UU Ri) (RR Di Ri UU Ri)"
		}
		
		static let chameleon = builtInOLL(number: 24, name: "Chameleon") {
			"(r U Ri Ui) (ri F R Fi)"
		}
		
		static let bowtie = builtInOLL(number: 25, name: "Bowtie") {
			"Fi (r U Ri Ui) (ri F R _)"
		}
	}
}

private func builtInOLL(
	number: Int,
	name: String,
	@ArrayBuilder<MoveSequence> variants: () -> [MoveSequence]
) -> Algorithm {
	.builtIn(id: "oll \(number)", name: "\(name) (OLL \(number))", configuration: .computedOLL, variants: variants)
}
