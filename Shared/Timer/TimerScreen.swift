import SwiftUI
import HandyOperators
import ArrayBuilder
import UserDefault

struct TimerScreen: View {
	@StateObject var stopwatch = Stopwatch()
	@StateObject var storage = ResultsStorage()
	@State var latestResult: TimerResult?
	
	var body: some View {
		ZStack {
			AdaptiveStack(spacing: 16) {
				Group {
					storedResultsArea
					timerArea
				}
				.background(Color.groupedContentBackground)
				.cornerRadius(16)
			}
			.compositingGroup()
			.shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
			.padding()
			.background(Color.groupedBackground)
			
			VStack { // transitions don't work in ZStacks
				if stopwatch.isRunning {
					stopOverlay
				}
			}
		}
	}
	
	var stopOverlay: some View {
		VStack(spacing: 0) {
			timerText
				.font(.system(size: 64))
				.padding()
				.frame(maxWidth: .infinity)
			
			Button("STOP") {
				withAnimation {
					latestResult = stopwatch.stop()
				}
			}
			.font(.system(size: 64, weight: .bold, design: .rounded))
			.buttonStyle(.spaceFilling)
		}
		.background(Color(.systemBackground), ignoresSafeAreaEdges: .all)
		.transition(.move(edge: .bottom))
		.transition(.slide)
	}
	
	@ViewBuilder
	var timerArea: some View {
		VStack(spacing: 0) {
			timerText
				.font(
					.system(size: 48)
						.weight(stopwatch.isRunning ? .light : .medium)
						.monospacedDigit()
				)
				.padding()
			
			Divider()
			
			if let latestResult = latestResult {
				VStack {
					Button {
						storage.results.insert(latestResult, at: 0)
						self.latestResult = nil
					} label: {
						Label("Store Result", systemImage: "square.and.arrow.down")
					}
					
					Button(role: .destructive) {
						self.latestResult = nil
					} label: {
						Label("Discard Result", systemImage: "trash")
					}
				}
				.padding()
			} else {
				Button {
					withAnimation(.default.speed(2)) {
						stopwatch.start()
					}
				} label: {
					Text("Start Timer")
						.fontWeight(.bold)
						.padding(10)
				}
				.padding()
				.frame(maxWidth: .infinity)
				.buttonStyle(.borderedProminent)
			}
		}
		.buttonStyle(.bordered)
	}
	
	var timerText: some View {
		Text(
			latestResult?.timeTaken ?? stopwatch.elapsedTime,
			format: TimeIntervalFormatStyle()
		)
	}
	
	@ViewBuilder
	var storedResultsArea: some View {
		if storage.results.isEmpty {
			Text("No times saved yet!")
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		} else {
			NavigationView {
				StoredResultsList(storedResults: $storage.results)
					.background(Color.groupedContentBackground, ignoresSafeAreaEdges: .all)
			}
			.navigationViewStyle(.stack)
		}
	}
}

struct StoredResultsList: View {
	@Binding var storedResults: [TimerResult]
	
	var body: some View {
		List {
			ForEach($storedResults) { $result in
				HStack {
					result.finishTime.relativeText()
					
					Spacer()
					
					Text(result.timeTaken, format: TimeIntervalFormatStyle())
						.fontWeight(.medium)
				}
				.swipeActions {
					Button(role: .destructive) {
						storedResults.removeAll { $0.id == result.id }
					} label: {
						Label("Remove", systemImage: "trash")
					}
				}
				.listRowBackground(Color.groupedContentBackground)
			}
			.onDelete {
				storedResults.remove(atOffsets: $0)
			}
		}
		.listStyle(.plain)
		.navigationTitle("Previous Times")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar { EditButton() }
	}
}

extension PrimitiveButtonStyle where Self == SpaceFillingButtonStyle {
	static var spaceFilling: Self { .init() }
}

struct SpaceFillingButtonStyle: PrimitiveButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		Button(role: configuration.role, action: configuration.trigger) {
			configuration.label
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.foregroundColor(.white)
				.background(Color.accentColor)
		}
		.buttonStyle(.plain)
	}
}

/// Adaptively picks an HStack or VStack depending on available vertical size class.
struct AdaptiveStack<Content: View>: View {
	var spacing: CGFloat?
	@ViewBuilder var content: () -> Content
	
	@Environment(\.verticalSizeClass) var verticalSizeClass
	
	var body: some View {
		if verticalSizeClass == .regular {
			VStack(spacing: spacing) { content() }
		} else {
			HStack(spacing: spacing) { content() }
		}
	}
}

struct TimerScreen_Previews: PreviewProvider {
	static var previews: some View {
		let exampleResults: [TimerResult] = [
			.init(timeTaken: 20.21, finishTime: .init(timeIntervalSinceNow: -3456)),
			.init(timeTaken: 345.67, finishTime: .init(timeIntervalSinceNow: -12345)),
			.init(timeTaken: 51.35, finishTime: .init(timeIntervalSinceNow: -34567)),
			.init(timeTaken: 82.23, finishTime: .init(timeIntervalSinceNow: -56789)),
			.init(timeTaken: 37.39, finishTime: .init(timeIntervalSinceNow: -78901)),
			.init(timeTaken: 40.96, finishTime: .init(timeIntervalSinceNow: -90123)),
			.init(timeTaken: 81.92, finishTime: .init(timeIntervalSinceNow: -123456)),
			.init(timeTaken: 1310.72, finishTime: .init(timeIntervalSinceNow: -345678)),
			.init(timeTaken: 2621.44, finishTime: .init(timeIntervalSinceNow: -456789)),
			.init(timeTaken: 163.84, finishTime: .init(timeIntervalSinceNow: -567890)),
			.init(timeTaken: 327.68, finishTime: .init(timeIntervalSinceNow: -678901)),
			.init(timeTaken: 655.36, finishTime: .init(timeIntervalSinceNow: -789012)),
		]
		
		TimerScreen(storage: .init(results: exampleResults))
			.inEachColorScheme()
			.inEachOrientation()
		
		TimerScreen(
			storage: .init(results: Array(exampleResults.prefix(3))),
			latestResult: .init(timeTaken: 69.420, finishTime: .now)
		)
			.previewInterfaceOrientation(.landscapeLeft)
		
		TimerScreen(stopwatch: .init(startTime: .now, elapsedTime: 69.420))
			.inEachOrientation()
	}
}
