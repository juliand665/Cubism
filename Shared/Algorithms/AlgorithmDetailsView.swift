import SwiftUI

struct AlgorithmDetailsView: View {
	let algorithm: Algorithm
	@Binding var customization: AlgorithmCustomization
	
	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				if let configuration = algorithm.configuration {
					CubeConfigurationDiagram(configuration: configuration)
				}
				
				if !algorithm.description.isEmpty {
					GroupBox("Description") {
						Text(algorithm.description)
							.lineLimit(nil)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding()
					}
				}
				
				let variant = algorithm.preferredVariant(using: customization) ?? algorithm.variants.first!
				MoveSequenceView(moves: variant.moves)
				
				variantsList
			}
			.padding()
		}
		.groupBoxStyle(FooGroupBoxStyle())
		.navigationTitle(algorithm.name)
		.navigationBarTitleDisplayMode(.inline)
	}
	
	var variantsList: some View {
		GroupBox("Variants") {
			//sectionHeader("Built-in")
			
			ForEach(algorithm.variants) { variant in
				VariantRow(
					variant: variant,
					preferredVariant: $customization.preferredVariant
				)
			} separator: {
				Divider()
			}
			
			/*
			sectionHeader("Custom")
			
			ForEach(customization.customVariants) { variant in
				VariantRow(
					variant: variant,
					preferredVariant: $customization.preferredVariant
				)
			} separator: {
				Divider()
			}
			
			Button {
				// TODO
			} label: {
				Label("Add Custom Variant", systemImage: "plus")
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(12)
			}
			*/
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
			HStack {
				Group {
					if isSelected {
						Image(systemName: "largecircle.fill.circle")
					} else {
						Image(systemName: "circle")
					}
				}
				.foregroundColor(.accentColor)
				
				Text(variant.moves.description(using: StandardNotation.self))
					.fontWeight(isSelected ? .medium : .regular)
				
				Spacer()
			}
			.padding(12)
			.background(Color.accentColor.opacity(isSelected ? 0.25 : 0))
			.contentShape(Rectangle())
			.onTapGesture {
				preferredVariant = isSelected ? nil : variant.id
			}
		}
	}
}

struct FooGroupBoxStyle: GroupBoxStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack(spacing: 0) {
			configuration.label
				.font(.headline)
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			
			Divider()
			
			VStack(spacing: 0) {
				configuration.content
			}
		}
		.background(Color(.secondarySystemBackground))
		.cornerRadius(20)
	}
}

struct AlgorithmDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			AlgorithmDetailsView(algorithm: .edgeEndSwap, customization: .constant(.init()))
		}
		
		NavigationView {
			AlgorithmDetailsView(algorithm: .uPermA, customization: .constant(.init(
				nameOverride: "Better name",
				preferredVariant: Algorithm.uPermA.variants[1].id,
				rotation: 1,
				customVariants: [
					.init(id: .dynamic(.init()), moves: "R U Ri Ui")
				]
			)))
		}
		.inEachColorScheme()
	}
}
