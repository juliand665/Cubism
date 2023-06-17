import SwiftUI
import HandyOperators
import ArrayBuilder

struct TimerScreen: View {
	@StateObject var stopwatch = Stopwatch()
	@StateObject var storage = ResultsStorage()
	@StateObject var scrambler = ScrambleGenerator()
	@State var latestResult: TimerResult?
	
	var body: some View {
		NavigationStack {
			List {
				SectionBox(title: "Results") {
					storedResultsArea
				}
				SectionBox(title: "Timer") {
					timerArea
				}
				SectionBox(title: "Scramble") {
					scrambleArea
				}
			}
			.navigationTitle("Timer")
#if !os(macOS)
			.fullScreenCover(isPresented: .constant(stopwatch.isRunning)) {
				stopOverlay
			}
#endif
		}
	}
	
#if !os(macOS)
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
#endif
	
	var timerArea: some View {
		VStack(spacing: 16) {
			timerText
				.font(
					.system(size: 40)
						.weight(stopwatch.isRunning ? .light : .medium)
						.monospacedDigit()
				)
			
			#if os(macOS)
			if stopwatch.isRunning {
				Button {
					withAnimation {
						latestResult = stopwatch.stop()
					}
				} label: {
					Text("Stop Timer")
						.fontWeight(.bold)
						.padding(8)
				}
				.buttonStyle(.borderedProminent)
			} else {
				sharedTimerButtons
			}
			#else
			sharedTimerButtons
			#endif
		}
	}
	
	@ViewBuilder
	var sharedTimerButtons: some View {
		if let latestResult = latestResult {
			HStack {
				Button {
					storage.results.insert(latestResult, at: 0)
					self.latestResult = nil
				} label: {
					Label("Store Result", systemImage: "square.and.arrow.down")
				}
				
				Button(role: .destructive) {
					self.latestResult = nil
				} label: {
					Label("Discard", systemImage: "trash")
				}
			}
		} else {
			Button {
				withAnimation(.default.speed(2)) {
					stopwatch.start()
				}
			} label: {
				Text("Start Timer")
					.fontWeight(.bold)
					.padding(8)
			}
			.buttonStyle(.borderedProminent)
		}
	}
	
	var scrambleArea: some View {
		VStack(spacing: 12) {
			ScramblerView(scrambler: scrambler) {
				Button {
					Task { await scrambler.generate() }
				} label: {
					Label("Generate Scramble", systemImage: "shuffle")
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}
	
	var timerText: some View {
		Text(
			latestResult?.timeTaken ?? stopwatch.elapsedTime,
			format: .timeInterval
		)
	}
	
	@ViewBuilder
	var storedResultsArea: some View {
		VStack(spacing: 16) {
			if storage.results.isEmpty {
				Text("No times saved yet!")
					.foregroundStyle(.secondary)
			} else {
				VStack(spacing: 8) {
					timeRow(label: "Personal best:", time: storage.bestTime()!)
					
					ForEach(static: [5, 12, 25, 50, 100]) { count in
						if let average = storage.average(count: count) {
							timeRow(label: "Average of \(count):", time: average)
						}
					}
				}
				
				NavigationLink("View All Results") {
					StoredResultsList(storedResults: $storage.results)
				}
			}
		}
	}
	
	func timeRow(label: String, time: TimeInterval) -> some View {
		HStack {
			Text(label)
				.opacity(0.5)
			
			Spacer()
			
			Text(time, format: .timeInterval)
				.fontWeight(.medium)
		}
	}
}

struct ScramblerView<PrimaryAction: View>: View {
	@ObservedObject var scrambler: ScrambleGenerator
	
	@ViewBuilder var primaryAction: PrimaryAction
	
	var body: some View {
		switch scrambler.state {
		case nil:
			Button("Initialize Scrambler") {
				Task {
					await scrambler.prepare()
				}
			}
		case .preparing:
			progressView("Preparing Scrambler…")
		case .ready:
			primaryAction
		case .scrambling:
			primaryAction
				.disabled(true)
			progressView("Generating Scramble…")
		case .done(let scramble):
			primaryAction
			
			ScrambleView(scramble: scramble)
		}
	}
	
	func progressView(_ title: LocalizedStringKey) -> some View {
		ZStack {
			if let lastScramble = scrambler.lastScramble {
				ScrambleView(scramble: lastScramble).hidden()
			}
			ProgressView(title)
		}
	}
}

struct ScrambleView: View {
	var scramble: MoveSequence
	
	@AppStorage("showScrambleAsText") private var showScrambleAsText = true
	
	@Environment(\.settings.notation.notation) private var notation
	
	var body: some View {
		ZStack {
			if scramble.isEmpty {
				Text("Empty Scramble!")
					.foregroundColor(.secondary)
			} else {
				Menu {
					Toggle(isOn: $showScrambleAsText) {
						Label("Show as Text", systemImage: "textformat")
					}
					
					Button {
#if os(macOS)
						NSPasteboard.general.setString(scramble.description(using: notation), forType: .string)
#else
						UIPasteboard.general.string = scramble.description(using: notation)
#endif
					} label: {
						Label("Copy", systemImage: "doc.on.doc")
					}
				} label: {
					scrambleView()
				}
				.menuStyle(.borderlessButton)
			}
		}
	}
	
	@ViewBuilder
	func scrambleView() -> some View {
		if showScrambleAsText {
			MoveSequenceLabel(moves: scramble)
				.frame(maxWidth: .infinity, alignment: .leading)
		} else {
			MoveSequenceView(moves: scramble)
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
					
					Text(result.timeTaken, format: .timeInterval)
						.fontWeight(.medium)
				}
				.swipeActions {
					Button(role: .destructive) {
						storedResults.removeAll { $0.id == result.id }
					} label: {
						Label("Remove", systemImage: "trash")
					}
				}
			}
			.onDelete {
				storedResults.remove(atOffsets: $0)
			}
		}
		.navigationTitle("Previous Times")
		.inlineNavigationTitle()
		.toolbar {
#if !os(macOS)
			EditButton()
#endif
		}
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

#if DEBUG
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
		
		TimerScreen(scrambler: .mockInitialized())
		
		TimerScreen(scrambler: .mockInitialized(
			state: .done("R D' F2 D2 R2 B2 R2 B2 U2 F L2 B' D B2 F2 L R B")
		))
		
		TimerScreen(
			storage: .init(results: Array(exampleResults.prefix(3))),
			latestResult: .init(timeTaken: 69.420, finishTime: .now)
		)
		.previewInterfaceOrientation(.landscapeLeft)
		
		TimerScreen(stopwatch: .init(startTime: .now, elapsedTime: 69.420))
	}
}
#endif
