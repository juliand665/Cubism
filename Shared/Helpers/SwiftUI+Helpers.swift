import SwiftUI

extension Color {
	static let groupedBackground = Color(uiColor: .systemGroupedBackground)
	static let groupedContentBackground = Color(uiColor: .secondarySystemGroupedBackground)
}

extension ForEach where Content: View {
	init<StaticData: RandomAccessCollection>(
		static staticData: StaticData,
		@ViewBuilder content: @escaping (StaticData.Element) -> Content
	) where Data == Array<Foo<StaticData.Index>>, ID == Foo<StaticData.Index> {
		self.init(Array(staticData.indices.map(Foo.init)), id: \.self) { i in
			content(staticData[i.index])
		}
	}
	
	init<ElementView: View, SeparatorView: View>(
		_ data: Data,
		@ViewBuilder content: @escaping (Data.Element) -> ElementView,
		@ViewBuilder separator: @escaping () -> SeparatorView
	) where
		Data.Element: Identifiable,
		ID == Data.Element.ID,
		Content == TupleView<(ElementView, SeparatorView?)>
	{
		self.init(data) { element in
			content(element)
			
			if element.id != data.last?.id {
				separator()
			}
		}
	}
}

struct Foo<Index: Hashable>: Hashable {
	var index: Index
}

extension View {
	func sizeIndependent() -> some View {
		self
			.offset(x: 1, y: 1)
			.frame(width: 2, height: 2) // zero frames are treated as hidden
	}
}

extension HorizontalAlignment {
	static var compatibleListRowSeparatorLeading: Self {
		if #available(iOS 16.0, *) {
			return .listRowSeparatorLeading
		} else {
			struct Dummy: AlignmentID {
				static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.leading] }
			}
			return .init(Dummy.self)
		}
	}
}
