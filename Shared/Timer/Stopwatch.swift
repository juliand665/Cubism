import Foundation

final class Stopwatch: ObservableObject {
	@Published var startTime: Date?
	@Published var elapsedTime: TimeInterval
	
	init(startTime: Date? = nil, elapsedTime: TimeInterval = 0) {
		self.startTime = startTime
		self.elapsedTime = elapsedTime
	}
	
	var isRunning: Bool { startTime != nil }
	
	func start() {
		startTime = .now
		
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
			guard let self = self, let startTime = self.startTime else {
				timer.invalidate()
				return
			}
			
			self.elapsedTime = -startTime.timeIntervalSinceNow
		}
	}
	
	func stop() -> TimerResult {
		let now = Date.now
		let timeTaken = now.timeIntervalSince(startTime!)
		startTime = nil
		elapsedTime = 0
		return .init(timeTaken: timeTaken, finishTime: now)
	}
}
