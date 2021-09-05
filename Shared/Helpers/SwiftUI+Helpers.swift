import SwiftUI

extension Color {
	static let groupedBackground = Color(uiColor: .systemGroupedBackground)
	static let groupedContentBackground = Color(uiColor: .tertiarySystemBackground)
}

extension ForEach where Content: View {
	init<StaticData: RandomAccessCollection>(
		static staticData: StaticData,
		@ViewBuilder content: @escaping (StaticData.Element) -> Content
	) where Data == Array<StaticData.Index>, ID == StaticData.Index {
		self.init(Array(staticData.indices), id: \.self) { i in
			content(staticData[i])
		}
	}
}

extension View {
	func sizeIndependent() -> some View {
		self
			.offset(x: 1, y: 1)
			.frame(width: 2, height: 2) // zero frames are treated as hidden
	}
}
