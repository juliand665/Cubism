import SwiftUI

struct AlgorithmDetailsView: View {
	var algorithm: Algorithm
	@Binding var customization: AlgorithmCustomization
	@State var isAddingVariant = false
	
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
		.onDelete { toDelete in
			customization.customVariants.remove(atOffsets: toDelete)
		}
		.onMove { toMove, target in
			customization.customVariants.move(fromOffsets: toMove, toOffset: target)
		}
		
		Button {
			isAddingVariant = true
		} label: {
			Label("Add Custom Variant", systemImage: "plus")
		}
	}
	
	@ViewBuilder
	func sectionHeader(_ title: String) -> some View {
		Divider()
		
		Text(title)
			.font(.footnote.smallCaps())
			.padding(4)
			.foregroundColor(.secondary)
			.frame(maxWidth: .infinity)
			.background(Color.primary.opacity(0.05).blendMode(.destinationOut))
		
		Divider()
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
					Group {
						if isSelected {
							Image(systemName: "largecircle.fill.circle")
						} else {
							Image(systemName: "circle")
						}
					}
				}
			}
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
