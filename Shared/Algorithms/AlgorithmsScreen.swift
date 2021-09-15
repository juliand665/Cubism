import SwiftUI

struct AlgorithmsScreen: View {
	let collection = AlgorithmCollection.base
	
    var body: some View {
		NavigationView {
			List {
				ForEach(collection.folders) { folder in
					NavigationLink {
						AlgorithmsList(folder: folder)
					} label: {
						VStack(alignment: .leading, spacing: 4) {
							Text(folder.name).font(.headline)
							Text(folder.description).font(.footnote).foregroundStyle(.secondary)
						}
						.padding(.vertical, 8)
					}
				}
				
				Link(destination: URL(string: "https://jperm.net/3x3/moves")!) {
					Label("Notation", systemImage: "questionmark.circle")
				}
				.frame(maxWidth: .infinity)
			}
			.navigationTitle("Algorithms")
		}
		.environmentObject(AlgorithmCustomizer())
    }
}

struct AlgorithmsList: View {
	let folder: AlgorithmFolder
	
	var body: some View {
		List(folder.sections) { section in
			Section(section.name) {
				ForEach(section.algorithms) { algorithm in
					AlgorithmCell(algorithm: algorithm)
				}
			}
		}
		.navigationTitle(folder.name)
	}
}

struct AlgorithmCell: View {
	let algorithm: Algorithm
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		let customization = customizer[algorithm.id]
		NavigationLink {
			AlgorithmDetailsView(algorithm: algorithm, customization: $customizer[algorithm.id])
		} label: {
			HStack(spacing: 20) {
				if let configuration = algorithm.configuration {
					CubeConfigurationDiagram(configuration: configuration)
				}
				
				VStack(alignment: .leading, spacing: 4) {
					Text(customization.nameOverride ?? algorithm.name)
						.bold()
						.font(.subheadline)
						.foregroundStyle(.secondary)
					
					let variant = algorithm.preferredVariant(using: customization)
						?? algorithm.variants.first!
					Text(variant.moves.description(using: NaturalNotation.self)) // TODO: allow choosing notation
						.fixedSize(horizontal: false, vertical: true) // allow multiple lines
					
					let variantCount = algorithm.variants.count + customization.customVariants.count
					if variantCount > 1 {
						Text("\(variantCount) variants available")
							.font(.footnote)
							.foregroundColor(.secondary)
					}
				}
			}
			.padding(.vertical, 6)
		}
	}
}

extension MoveSequence {
	private static let thinSpace = Character(UnicodeScalar(0x2009)!)
	private static let moveSpacing = String(repeating: thinSpace, count: 0) + " "
	
	func description(using notation: Notation.Type = StandardNotation.self) -> String {
		moves.map(notation.description(for:)).joined(separator: Self.moveSpacing)
	}
}

struct AlgorithmsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlgorithmsScreen()
			.inEachColorScheme()
		
		NavigationView {
			AlgorithmsList(folder: .twoLookOLL)
				.environmentObject(AlgorithmCustomizer())
		}
		
		NavigationView {
			AlgorithmsList(folder: .fullPLL)
				.environmentObject(AlgorithmCustomizer())
		}
		.preferredColorScheme(.dark)
    }
}
