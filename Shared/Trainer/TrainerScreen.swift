import SwiftUI
import UserDefault
import HandyOperators

struct TrainerScreen: View {
	@AppStorage("TrainerScreen.shouldTrainOLLs")
	var shouldTrainOLLs = true
	@UserDefault.State("TrainerScreen.olls")
	var olls: Set<Algorithm.ID> = []
	
	@AppStorage("TrainerScreen.shouldTrainPLLs")
	var shouldTrainPLLs = true
	@UserDefault.State("TrainerScreen.plls")
	var plls: Set<Algorithm.ID> = []
	
	@State var scramble: MoveSequence?
	
    var body: some View {
		NavigationView {
			Form {
				Section("OLLs") {
					Toggle("Train OLLs", isOn: $shouldTrainOLLs)
					
					NavigationLink {
						AlgorithmPicker(folder: .fullOLL, selection: $olls)
					} label: {
						HStack {
							Text("Choose Algorithms")
							Spacer()
							Text("\(olls.count)")
								.foregroundColor(.secondary)
						}
					}
					.disabled(!shouldTrainOLLs)
				}
				
				Section("PLLs") {
					Toggle("Train PLLs", isOn: $shouldTrainPLLs)
					
					NavigationLink {
						AlgorithmPicker(folder: .fullPLL, selection: $plls)
					} label: {
						HStack {
							Text("Choose Algorithms")
							Spacer()
							Text("\(plls.count)")
								.foregroundColor(.secondary)
						}
					}
					.disabled(!shouldTrainPLLs)
				}
				
				Section("Train") {
					if let scramble = scramble {
						ScrambleView(scramble: scramble)
					}
					
					Button("Generate Scramble", action: generateScramble)
				}
			}
			.navigationTitle("Algorithm Trainer")
		}
    }
	
	func generateScramble() {
		let state = CubeTransformation.zero <- { state in
			let uTurns = CubeTransformation.singleU.uniqueApplications()
			
			state += uTurns.randomElement()!
			
			let pllOptions = AlgorithmFolder.fullPLL.sections
				.lazy
				.flatMap(\.algorithms)
				.filter { plls.contains($0.id) }
			if shouldTrainPLLs, let algorithm = pllOptions.randomElement() {
				let transform = try! algorithm.variants.first!.moves.transformReversingRotations()
				state += transform
			}
			
			state += uTurns.randomElement()!
			
			let ollOptions = AlgorithmFolder.fullOLL.sections
				.lazy
				.flatMap(\.algorithms)
				.filter { olls.contains($0.id) }
			if shouldTrainOLLs, let algorithm = ollOptions.randomElement() {
				let transform = try! algorithm.variants.first!.moves.transformReversingRotations()
				state += transform
			}
			
			state += uTurns.randomElement()!
		}
		
		let solver = ThreeWayTwoPhaseSolver(start: state)
		solver.searchNextLevel()
		scramble = solver.bestSolution.map(MoveSequence.init)
	}
}

struct AlgorithmPicker: View {
	var folder: AlgorithmFolder
	@Binding var selection: Set<Algorithm.ID>
	
	var body: some View {
		List {
			ForEach(folder.sections) { section in
				Section(section.name) {
					ForEach(section.algorithms, content: algorithmCell(for:))
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .bottomBar) {
				Button("Select All") {
					selection = .init(folder.sections.lazy.flatMap(\.algorithms).map(\.id))
				}
				
				Button("Select None") {
					selection = []
				}
			}
		}
		.navigationTitle("Choose Algorithms")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	func algorithmCell(for algorithm: Algorithm) -> some View {
		Button {
			selection.formSymmetricDifference([algorithm.id])
		} label: {
			let isSelected = selection.contains(algorithm.id)
			HStack {
				AlgorithmLabel(algorithm: algorithm)
					.foregroundColor(.primary)
				Spacer()
				Image(systemName: "checkmark")
					.opacity(isSelected ? 1 : 0)
			}
		}
	}
}

extension ExtensibleID: DefaultsValueConvertible {
	typealias DefaultsRepresentation = Data
}

struct TrainerScreen_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			TrainerScreen()
		}
		.environmentObject(AlgorithmCustomizer())
		
		NavigationView {
			AlgorithmPicker(folder: .fullPLL, selection: .constant([
				.builtIn("u perm a"),
				.builtIn("z perm"),
			]))
		}
		.environmentObject(AlgorithmCustomizer())
		.previewDisplayName("Algorithm Picker")
    }
}
