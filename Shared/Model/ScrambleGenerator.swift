import SwiftUI
import HandyOperators

@MainActor
final class ScrambleGenerator: ObservableObject {
#if DEBUG
	static func mockInitialized(state: State = .ready) -> Self {
		.init() <- { $0.state = state }
	}
#endif
	
	@Published private(set) var state: State?
	@Published private(set) var lastScramble: MoveSequence? // to keep space in layouts
	
	func prepare() async {
		guard state == nil else { return }
		state = .preparing
		// TODO: find a nice way to indicate progress
		let basicState: CubeTransformation = .singleR + .singleF
		await Task.detached(priority: .userInitiated) {
			BasicTwoPhaseSolver(start: basicState).searchNextLevel()
		}.value
		state = .ready
	}
	
	func generate() async {
		await solve(from: .random())
	}
	
	func solve(from start: CubeTransformation) async {
		await computeScramble {
			ThreeWayTwoPhaseSolver(start: start).search()
		}
	}
	
	func solve(to end: CubeTransformation) async {
		await computeScramble {
			-ThreeWayTwoPhaseSolver(start: end).search()
		}
	}
	
	func computeScramble(compute: @escaping () -> SolverManeuver) async {
		state = .scrambling
		let maneuver = await Task.detached(priority: .userInitiated) {
			compute()
		}.value
		let scramble = MoveSequence(maneuver)
		lastScramble = scramble
		state = .done(scramble)
	}
	
	enum State: Hashable {
		case preparing
		case ready
		case scrambling
		case done(MoveSequence)
	}
}
