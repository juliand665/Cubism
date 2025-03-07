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
	
	@StateObject var scrambler = ScrambleGenerator()
	
    var body: some View {
		NavigationStack {
			Form {
				Section {
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
				} header: {
					Text("OLLs")
				} footer: {
					if shouldTrainOLLs {
						Text("Since some OLLs are symmetrical, you may receive a PLL you did not select (if any) because you solved it from a different angle than it was generated.")
							.foregroundStyle(.secondary)
							.font(.footnote)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
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
				
				SectionBox(title: "Train") {
					VStack(spacing: 12) {
						ScramblerView(scrambler: scrambler) {
							Button("Generate Scramble", action: generateScramble)
						}
					}
				}
			}
			.navigationTitle("Algorithm Trainer")
		}
    }
	
	func generateScramble() {
		let state = CubeTransformation.zero <- { state in
			let uTurns = CubeTransformation.singleU.uniqueApplications()
			
			state += uTurns.randomElement()!
			
            let ollOptions = AlgorithmFolder.fullOLL.allAlgorithms.filter { olls.contains($0.id) }
            if shouldTrainOLLs, let algorithm = ollOptions.randomElement() {
                let transform = try! algorithm.variants.first!.moves.transformReversingRotations()
                // TODO: intuitively i would have expected this to need to be -=, but somehow += makes it work as expected?? not sure what's up with that
                state += transform
            }
            
			state += uTurns.randomElement()!
			
            let pllOptions = AlgorithmFolder.fullPLL.allAlgorithms.filter { plls.contains($0.id) }
            if shouldTrainPLLs, let algorithm = pllOptions.randomElement() {
                let transform = try! algorithm.variants.first!.moves.transformReversingRotations()
                state += transform
            }
            
			state += uTurns.randomElement()!
		}
		
		Task {
			await scrambler.solve(from: state)
		}
	}
}

struct AlgorithmPicker: View {
	var folder: AlgorithmFolder
	@Binding var selection: Set<Algorithm.ID>
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		List {
			ForEach(folder.sections) { section in
				Section(section.name) {
					ForEach(section.algorithms, content: algorithmCell(for:))
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .principal) {
				Button("Select All") {
					selection = .init(folder.allAlgorithms.map(\.id))
				}
				
				Button("Select None") {
					selection = []
				}
				
				Menu {
					ForEach(customizer.allTags) { tag in
						Button(tag.name) {
							selection = .init(
								folder.allAlgorithms
									.map(\.id)
									.filter { customizer[$0].tags.contains(tag) }
							)
						}
					}
				} label: {
					Label("Select by Tag", systemImage: "tag")
				}
				
				Spacer()
			}
		}
		.navigationTitle("Choose Algorithms")
		.inlineNavigationTitle()
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
		TrainerScreen()
			.environmentObject(AlgorithmCustomizer())
		
		NavigationStack {
			AlgorithmPicker(folder: .fullPLL, selection: .constant([
				.builtIn("u perm a"),
				.builtIn("z perm"),
			]))
		}
		.environmentObject(AlgorithmCustomizer())
		.previewDisplayName("Algorithm Picker")
    }
}
