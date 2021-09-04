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
}

extension TimerResult: DefaultsValueConvertible {}
