import SwiftUI
import HandyOperators

extension Date {
	private static let startDateFormatter = DateFormatter() <- {
		$0.dateStyle = .short
	}
	private static let startTimeFormatter = DateFormatter() <- {
		$0.timeStyle = .short
	}
	private static let relativeStartTimeFormatter = DateComponentsFormatter() <- {
		// DateComponentsFormatter gives us more control than RelativeDateTimeFormatter
		$0.unitsStyle = .abbreviated
		$0.maximumUnitCount = 2
		$0.allowedUnits = [.day, .hour, .minute]
	}
	
	/// uses relative formatting for times less than a day ago
	func relativeText() -> some View {
		HStack {
			let relativeCutoff = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
			if self > relativeCutoff {
				let formatter = Self.relativeStartTimeFormatter
				Text("\(formatter.string(from: self, to: .now)!) ago")
					.foregroundStyle(.secondary)
			} else {
				Text(self, formatter: Self.startDateFormatter)
				Text(self, formatter: Self.startTimeFormatter)
					.foregroundStyle(.secondary)
			}
		}
	}
}

struct TimeIntervalFormatStyle: FormatStyle {
	typealias FormatInput = TimeInterval
	typealias FormatOutput = String
	
	func format(_ seconds: TimeInterval) -> String {
		let minutes = Int(seconds / 60)
		let secondsWithinMinute = seconds.truncatingRemainder(dividingBy: 60)
		return [String].build {
			if minutes > 0 {
				"\(minutes):"
			}
			secondsWithinMinute
				.formatted(FloatingPointFormatStyle().precision(.integerAndFractionLength(
					integerLimits: minutes > 0 ? 2...2 : 1...2,
					fractionLimits: 2...2
				)))
		}.joined()
	}
}
