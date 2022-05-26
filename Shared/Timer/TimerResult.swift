import Foundation
import UserDefault

struct TimerResult: Identifiable, Codable {
	let id = UUID()
	var timeTaken: TimeInterval
	var finishTime: Date
	
	private enum CodingKeys: String, CodingKey {
		case timeTaken
		case finishTime
	}
}

@MainActor
final class ResultsStorage: ObservableObject {
	@UserDefault("ResultsStorage.stored")
	private static var stored: [TimerResult] = []
	
	@Published var results: [TimerResult] {
		didSet { Self.stored = results }
	}
	
	init(results: [TimerResult]? = nil) {
		self.results = results ?? Self.stored
	}
	
	func bestTime() -> TimeInterval? {
		results.lazy.map(\.timeTaken).min()
	}
	
	func average(count: Int) -> TimeInterval? {
		guard results.count >= count else { return nil }
		let skippedCount = Int(ceil(0.05 * Double(count)))
		let considered = results
			.prefix(count)
			.map(\.timeTaken)
			.sorted()
			.dropFirst(skippedCount)
			.dropLast(skippedCount)
		return considered.sum() / .init(considered.count)
	}
}

extension TimerResult: DefaultsValueConvertible {}
