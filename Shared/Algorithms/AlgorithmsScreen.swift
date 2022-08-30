import SwiftUI
import UserDefault

struct AlgorithmsScreen: View {
	let collection = AlgorithmCollection.base
	
	@UserDefault.State("AlgorithmsScreen.tagFilter") var tagFilter: Tag?
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		NavigationView {
			List {
				ForEach(collection.folders) { folder in
					NavigationLink {
						AlgorithmsList(folder: folder, tagFilter: $tagFilter)
					} label: {
						folderCell(for: folder)
					}
				}
				
				Link(destination: URL(string: "https://jperm.net/3x3/moves")!) {
					Label("Notation", systemImage: "questionmark.circle")
				}
				.frame(maxWidth: .infinity)
			}
			.navigationTitle("Algorithms")
			.toolbar {
				TagFilterButton(filter: $tagFilter)
			}
		}
	}
	
	func folderCell(for folder: AlgorithmFolder) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 8) {
				Text(folder.name)
					.font(.headline)
				Text(folder.description)
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
			
			Spacer()
			
			let algorithmCount = folder.allAlgorithms.count
			if let tagFilter {
				VStack(alignment: .trailing, spacing: 4) {
					let taggedCount = folder.allAlgorithms
						.count { customizer[$0.id].tags.contains(tagFilter) }
					
					Text("\(taggedCount)/\(algorithmCount) \(Image(systemName: "tag"))")
				}
				.font(.footnote)
				.fixedSize()
			} else {
				Text("\(algorithmCount)")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
		}
		.padding(.vertical, 8)
	}
}

struct AlgorithmsList: View {
	let folder: AlgorithmFolder
	
	@Binding var tagFilter: Tag?
	
	var body: some View {
		List(folder.sections) { section in
			Section(section.name) {
				ForEach(section.algorithms) { algorithm in
					AlgorithmCell(algorithm: algorithm, tagFilter: tagFilter)
				}
			}
		}
		.navigationTitle(folder.name)
		.toolbar {
			TagFilterButton(filter: $tagFilter)
		}
	}
}

struct TagFilterButton: View {
	@Binding var filter: Tag?
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		Menu {
			Section("Show Tag Status for:") {
				ForEach(customizer.allTags) { tag in
					Button {
						filter = filter == tag ? nil : tag
					} label: {
						Text(tag.name)
						
						if filter == tag {
							Image(systemName: "checkmark")
						}
					}
				}
			}
		} label: {
			Label("Show Tag Status", systemImage: "tag")
				.symbolVariant(filter != nil ? .fill : .none)
		}
	}
}

struct AlgorithmCell: View {
	let algorithm: Algorithm
	let tagFilter: Tag?
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		NavigationLink {
			AlgorithmDetailsView(algorithm: algorithm, customization: $customizer[algorithm.id])
		} label: {
			AlgorithmLabel(algorithm: algorithm, tagFilter: tagFilter)
		}
		.swipeActions {
			if let tagFilter {
				Button {
					customizer[algorithm.id].tags.formSymmetricDifference([tagFilter])
				} label: {
					if customizer[algorithm.id].tags.contains(tagFilter) {
						Label("Remove Tag \"\(tagFilter.name)\"", systemImage: "tag.slash")
					} else {
						Label("Mark as \(tagFilter.name)", systemImage: "tag")
					}
				}
			}
		}
	}
}

struct AlgorithmLabel: View {
	var algorithm: Algorithm
	var tagFilter: Tag?
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		HStack(spacing: 20) {
			let customization = customizer[algorithm.id]
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
			
			Spacer()
			
			if let tagFilter {
				Image(systemName: "tag")
					.symbolVariant(customization.tags.contains(tagFilter) ? .fill : .none)
			}
		}
		.padding(.vertical, 6)
	}
}

extension MoveSequence {
	private static let thinSpace = Character(UnicodeScalar(0x2009)!)
	private static let moveSpacing = String(repeating: thinSpace, count: 0) + " "
	
	func description(using notation: Notation.Type = StandardNotation.self) -> String {
		moves.map(notation.description(for:)).joined(separator: Self.moveSpacing)
	}
}

extension Tag: DefaultsValueConvertible {}

struct AlgorithmsScreen_Previews: PreviewProvider {
	static var previews: some View {
		AlgorithmsScreen()
		
		NavigationView {
			AlgorithmsList(folder: .twoLookOLL, tagFilter: .constant(.known))
				.environmentObject(AlgorithmCustomizer())
		}
		
		NavigationView {
			AlgorithmsList(folder: .fullPLL, tagFilter: .constant(nil))
				.environmentObject(AlgorithmCustomizer())
		}
		.preferredColorScheme(.dark)
	}
}
