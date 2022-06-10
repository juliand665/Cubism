import Foundation

extension AlgorithmCollection {
	static let base: Self = {
		let start = Date()
		let collection = Self(folders: [
			.twoLookOLL,
			.simplifiedPLL,
			.fullPLL,
			.miscellaneous,
			.bigCubes,
		])
		print("base algorithms loaded in \(-start.timeIntervalSinceNow) seconds")
		return collection
	}()
}
