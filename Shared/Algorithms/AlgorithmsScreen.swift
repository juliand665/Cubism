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
	let folder: AlgorithmCollection.Folder
	
	var body: some View {
		List(folder.algorithms) { algorithm in
			AlgorithmCell(algorithm: algorithm)
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
					Text(variant.description(using: NaturalNotation.self)) // TODO: allow choosing notation
				}
			}
		}
		.padding(.vertical, 8)
	}
}

struct AlgorithmsScreen_Previews: PreviewProvider {
    static var previews: some View {
        AlgorithmsScreen()
		
		NavigationView {
			AlgorithmsList(folder: .twoLookOLL)
		}
		.inEachColorScheme()
		
		NavigationView {
			AlgorithmsList(folder: .minimalPLL)
		}
		.inEachColorScheme()
    }
}
