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
	
	var body: some View {
		HStack(spacing: 20) {
			if let configuration = algorithm.configuration {
				CubeConfigurationDiagram(configuration: configuration)
			}
			
			VStack(alignment: .leading, spacing: 8) {
				Text(algorithm.name).bold().foregroundStyle(.secondary)
				
				ForEach(static: algorithm.variants) { variant in
					Divider().opacity(0.5)
					
					Text(variant.description(using: NaturalNotation.self)) // TODO: allow choosing notation
						.fixedSize(horizontal: false, vertical: true) // allow multiple lines
				}
			}
		}
		.padding(.vertical, 12)
	}
}

extension MoveSequence {
	private static let thinSpace = Character(UnicodeScalar(0x2009)!)
	private static let moveSpacing = String(repeating: thinSpace, count: 0) + " "
	
	func description(using notation: Notation.Type) -> String {
		moves.map(notation.description(for:)).joined(separator: Self.moveSpacing)
	}
}

struct AlgorithmsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlgorithmsScreen()
			.inEachColorScheme()
		
		NavigationView {
			AlgorithmsList(folder: .twoLookOLL)
		}
		
		NavigationView {
			AlgorithmsList(folder: .fullPLL)
		}
		.preferredColorScheme(.dark)
    }
}
