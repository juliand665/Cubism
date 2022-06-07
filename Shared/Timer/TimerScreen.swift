import SwiftUI
import HandyOperators
import ArrayBuilder

struct TimerScreen: View {
	@StateObject var stopwatch = Stopwatch()
	@StateObject var storage = ResultsStorage()
	@State var latestResult: TimerResult?
	@State var scramble: MoveSequence?
	@AppStorage("showScrambleAsText") var showScrambleAsText = true
	
	var body: some View {
		NavigationView {
			ZStack {
				VStack(spacing: 16) {
					box { timerArea }
					box { storedResultsArea }
					box { scrambleArea }
					Spacer(minLength: 0)
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
			.navigationTitle("Timer")
		}
		.navigationViewStyle(.stack)
	}
	
	func box<Content: View>(@ViewBuilder content: () -> Content) -> some View {
		content()
			.buttonStyle(.bordered)
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.groupedContentBackground)
			.cornerRadius(16)
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
	
	var timerArea: some View {
		VStack(spacing: 16) {
			timerText
				.font(
					.system(size: 40)
						.weight(stopwatch.isRunning ? .light : .medium)
						.monospacedDigit()
				)
			
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
	}
	
	@State private var isPreparingScrambler = false
	var scrambleArea: some View {
		VStack(spacing: 16) {
			if ScrambleGenerator.isPrepared {
				if let scramble = scramble {
					ZStack {
						if showScrambleAsText {
							Text(scramble.description())
								.textSelection(.enabled)
								.fixedSize(horizontal: false, vertical: true)
								.frame(maxWidth: .infinity, alignment: .leading)
						} else {
							MoveSequenceView(moves: scramble)
						}
					}
					.onTapGesture {
						showScrambleAsText.toggle()
					}
					
					Button {
						UIPasteboard.general.string = scramble.description()
					} label: {
						Label("Copy", systemImage: "doc.on.doc")
					}
					.buttonStyle(.borderless)
				}
				
				Button {
					scramble = ScrambleGenerator.generate()
				} label: {
					Label("Generate Scramble", systemImage: "shuffle")
				}
			} else {
				ZStack {
					if isPreparingScrambler {
						ProgressView()
					}
					
					Button("Initialize Scrambler") {
						isPreparingScrambler = true
						Task {
							await ScrambleGenerator.prepare()
							isPreparingScrambler = false
						}
					}
					.disabled(isPreparingScrambler)
					.opacity(isPreparingScrambler ? 0.5 : 1)
				}
			}
		}
	}
	
	var timerText: some View {
		Text(
			latestResult?.timeTaken ?? stopwatch.elapsedTime,
			format: TimeIntervalFormatStyle()
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
				
				NavigationLink {
					StoredResultsList(storedResults: $storage.results)
						.background(Color.groupedContentBackground, ignoresSafeAreaEdges: .all)
				} label: {
					HStack {
						Text("View All Results")
						Image(systemName: "chevron.right")
					}
				}
			}
		}
	}
	
	func timeRow(label: String, time: TimeInterval) -> some View {
		HStack {
			Text(label)
				.opacity(0.5)
			
			Spacer()
			
			Text(time, format: TimeIntervalFormatStyle())
				.fontWeight(.medium)
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
			}
			.onDelete {
				storedResults.remove(atOffsets: $0)
			}
		}
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
			.inEachColorScheme()
			.inEachOrientation()
		
		let _ = ScrambleGenerator.mockInitializeForPreviews()
		TimerScreen(scramble: "R D' F2 D2 R2 B2 R2 B2 U2 F L2 B' D B2 F2 L R B")
		TimerScreen(scramble: "R D' F2 D2 R2 B2 R2 B2 U2 F L2 B' D B2 F2 L R B", showScrambleAsText: false)
			.preferredColorScheme(.dark)
		
		TimerScreen(
			storage: .init(results: Array(exampleResults.prefix(3))),
			latestResult: .init(timeTaken: 69.420, finishTime: .now)
		)
			.previewInterfaceOrientation(.landscapeLeft)
		
		TimerScreen(stopwatch: .init(startTime: .now, elapsedTime: 69.420))
			.inEachOrientation()
	}
}
#endif
