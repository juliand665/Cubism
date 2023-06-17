import SwiftUI

extension View {
	func foregroundColor(increasingContrastOf color: Color?, by contrast: CGFloat = 0.1) -> some View {
		modifier(AdjustedForegroundColor(color: color, contrast: contrast))
	}
}

private struct AdjustedForegroundColor: ViewModifier {
	let color: Color?
	let contrast: CGFloat
	
	@Environment(\.colorScheme) private var colorScheme
	
	func body(content: Content) -> some View {
		content
			.foregroundColor(color?.darkened(strength: colorScheme == .light ? 3 * contrast : 0))
			.brightness(colorScheme == .dark ? contrast : 0.0)
	}
}

#if os(macOS)
private typealias PlatformColor = NSColor
#else
private typealias PlatformColor = UIColor
#endif

extension Color {
	func darkened(strength: CGFloat) -> Self {
		guard strength > 0 else { return self }
		let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
		
		let color = PlatformColor(self).cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil)!
		
		var components = color.components!
		var remaining = strength
		for i in [1, 0, 2] { // darken green, then red, then blue—results in pretty hue-shifting
			if components[i] < remaining {
				remaining -= components[i]
				components[i] = 0
			} else {
				components[i] -= remaining
				break
			}
		}
		
		return .init(CGColor(colorSpace: colorSpace, components: &components)!)
	}
}
