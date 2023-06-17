import SwiftUI

struct SectionBox<Content: View>: View {
	var title: LocalizedStringKey?
	@ViewBuilder var content: Content
	
	var body: some View {
		Section {
			VStack {
				content
			}
			.padding(.vertical, 4)
			.buttonStyle(.bordered)
			.labelStyle(.titleAndIcon) // lists mess this up for bordered buttons
			.frame(maxWidth: .infinity)
		} header: {
			title.map { Text($0) }
		}
	}
}
