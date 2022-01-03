import Foundation
import HandyOperators

func measureTime<Result>(as title: String? = nil, for block: () throws -> Result) rethrows -> Result {
	if let title = title {
		print("measuring \(title)…")
	}
	
	let start = Date()
	let result = try block()
	let timeTaken = -start.timeIntervalSinceNow
	let formatter = NumberFormatter() <- { $0.minimumFractionDigits = 6 }
	print("done in \(formatter.string(from: timeTaken as NSNumber)!)s")
	print()
	return result
}

func benchmark<T>(as title: String? = nil, repetitions: Int, for block: () -> T) -> Void {
	measureTime(as: title.map { "\(repetitions)x \($0)" }) {
		for _ in 1...repetitions {
			_ = block()
		}
	}
}
