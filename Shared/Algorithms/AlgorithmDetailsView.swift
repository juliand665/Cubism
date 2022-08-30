import SwiftUI

struct AlgorithmDetailsView: View {
	var algorithm: Algorithm
	@Binding var customization: AlgorithmCustomization
	@State var isAddingVariant = false
	
	@EnvironmentObject private var customizer: AlgorithmCustomizer
	
	var body: some View {
		List {
			Section {
				if let configuration = algorithm.configuration {
					CubeConfigurationDiagram(configuration: configuration, scale: 2)
						.frame(maxWidth: .infinity)
						.listRowBackground(EmptyView())
				}
			}
			
			if !algorithm.description.isEmpty {
				Section("Description") {
					Text(algorithm.description)
						.lineLimit(nil)
				}
			}
			
			Section("Variants") {
				let variant = algorithm.preferredVariant(using: customization) ?? algorithm.variants.first!
				MoveSequenceView(moves: variant.moves)
				
				variantsList
			}
			
			Section("Tags") {
				tagsList
			}
		}
		.toolbar {
			EditButton()
		}
		.sheet(isPresented: $isAddingVariant) {
			NavigationView {
				AddVariantSheet(algorithm: algorithm) { variant in
					customization.customVariants.append(variant)
				}
			}
		}
		.navigationTitle(algorithm.name)
		.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	var variantsList: some View {
		ForEach(algorithm.variants) { variant in
			VariantRow(
				variant: variant,
				preferredVariant: $customization.preferredVariant
			)
		}
		
		ForEach(customization.customVariants) { variant in
			VariantRow(
				variant: variant,
				preferredVariant: $customization.preferredVariant
			)
		}
		.withEditActions($collection: $customization.customVariants)
		
		Button {
			isAddingVariant = true
		} label: {
			Label("Add Custom Variant", systemImage: "plus")
		}
	}
	
	@ViewBuilder
	var tagsList: some View {
		ForEach(Tag.predefinedTags) { tag in
			TagRow(tag: .constant(tag), isApplied: $customization[tag], isPredefined: true)
		}
		
		ForEach($customizer.userDefinedTags) { $tag in
			TagRow(tag: $tag, isApplied: $customization[tag], isPredefined: false)
		}
		.withEditActions($collection: $customizer.userDefinedTags)
		
		Button {
			customizer.userDefinedTags.append(.init(name: "New Tag", id: .newDynamic()))
		} label: {
			Label("Add Custom Tag", systemImage: "plus")
		}
	}
	
	struct VariantRow: View {
		var variant: Algorithm.Variant
		
		@Binding var preferredVariant: Algorithm.Variant.ID?
		
		var body: some View {
			let isSelected = preferredVariant == variant.id
			Button {
				preferredVariant = isSelected ? nil : variant.id
			} label: {
				// using a label to get the same spacing as the add button
				Label {
					Text(variant.moves.description(using: StandardNotation.self))
						.fontWeight(isSelected ? .medium : .regular)
						.foregroundColor(.primary)
				} icon: {
					if isSelected {
						Image(systemName: "largecircle.fill.circle")
					} else {
						Image(systemName: "circle")
					}
				}
			}
		}
	}
	
	struct TagRow: View {
		@Binding var tag: Tag
		@Binding var isApplied: Bool
		var isPredefined: Bool
		
		var body: some View {
			Button {
				isApplied.toggle()
			} label: {
				HStack {
					Label {
						nameLabel
							.foregroundColor(.primary)
					} icon: {
						Image(systemName: "tag")
							.symbolVariant(isApplied ? .fill : .none)
					}
				}
				.font(.body.weight(isApplied ? .medium : .regular))
			}
		}
		
		@ViewBuilder
		var nameLabel: some View {
			if !isPredefined {
				TextField("Name", text: $tag.name)
			} else {
				Text(tag.name)
			}
		}
	}
}

extension ForEach where Content: View {
	func withEditActions<T>(@Binding collection: [T]) -> some View {
		self
			.onDelete { toDelete in
				collection.remove(atOffsets: toDelete)
			}
			.onMove { toMove, target in
				collection.move(fromOffsets: toMove, toOffset: target)
			}
	}
}

struct AlgorithmDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			AlgorithmDetailsView(algorithm: .uPermA, customization: .constant(.init(
				nameOverride: "Better name",
				preferredVariant: Algorithm.uPermA.variants[1].id,
				rotation: 1,
				customVariants: [
					.init(id: .newDynamic(), moves: "U R Ui Ri"),
					.init(id: .newDynamic(), moves: "R U Ri Ui R U Ri Ui R U Ri Ui R U Ri Ui R U Ri Ui"),
				]
			)))
		}
		
		NavigationView {
			AlgorithmDetailsView(algorithm: .edgeEndSwap, customization: .constant(.init()))
		}
		.previewDisplayName("No Configuration")
	}
}
