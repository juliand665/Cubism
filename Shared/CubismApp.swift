import SwiftUI

@main
struct CubismApp: App {
	@State var settings = AppSettings()
	
	var body: some Scene {
		WindowGroup {
			ContentView(settings: $settings)
				.environment(\.settings, settings)
		}
	}
}
