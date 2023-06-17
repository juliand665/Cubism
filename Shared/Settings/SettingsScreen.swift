import SwiftUI

struct SettingsScreen: View {
	@Binding var settings: AppSettings
	
    var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink {
						NotationPicker(selection: $settings.notation)
					} label: {
						HStack {
							Text("Notation")
							
							Spacer()
							
							settings.notation.label()
								.foregroundStyle(.secondary)
						}
					}
				}
			}
			.navigationTitle("Settings")
		}
    }
}

struct NotationPicker: View {
	@Binding var selection: NotationPreference
	
	var body: some View {
		List(NotationPreference.allCases, id: \.self) { notation in
			Section {
				Button {
					selection = notation
				} label: {
					row(for: notation)
				}
			}
		}
		.navigationTitle("Choose Notation")
	}
	
	private static let example: MoveSequence = "R Ui FF l di bb M Ei SS x yi zz 3Rw 2Ri"
	
	func row(for notation: NotationPreference) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 8) {
				VStack(alignment: .leading, spacing: 4) {
					notation.label()
						.font(.title3.weight(.semibold))
					
					description(for: notation)
						.foregroundStyle(.secondary)
						.tint(.primary)
				}
				
				Divider()
				
				Text(Self.example.description(using: notation.notation))
					.tint(.primary)
				
				MoveSequenceView(moves: Self.example, notationOverride: notation)
			}
			
			Image(systemName: "checkmark")
				.opacity(selection == notation ? 1 : 0)
				.fontWeight(.semibold)
		}
		.padding(.vertical, 8)
	}
	
	@ViewBuilder
	func description(for notation: NotationPreference) -> some View {
		switch notation {
		case .standard:
			Text("The established standard notation used in most places these days.")
		case .classic:
			Text("A notation inspired by the classic one used in official Rubik's guides from way back when. Easier to read or memorize for some.")
		}
	}
}

extension NotationPreference {
	@ViewBuilder
	func label() -> some View {
		switch self {
		case .standard:
			Text("Standard Notation")
		case .classic:
			Text("Classic Rubik's Notation")
		}
	}
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
		Container()
		
		NavigationStack {
			NotationPicker(selection: .constant(.standard))
		}
		.previewDisplayName("Notation Picker")
    }
	
	struct Container: View {
		@State var settings = AppSettings()
		
		var body: some View {
			SettingsScreen(settings: $settings)
				.environment(\.settings, settings)
		}
	}
}
