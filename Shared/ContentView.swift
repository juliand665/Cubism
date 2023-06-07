import SwiftUI

struct ContentView: View {
	@SceneStorage("ContentView.tab") var tab = Tab.timer
	
	@Binding var settings: AppSettings
	
	var body: some View {
		TabView(selection: $tab) {
			TimerScreen()
				.tabItem { Label("Timer", systemImage: "stopwatch") }
				.tag(Tab.timer)
			
			AlgorithmsScreen()
				.tabItem { Label("Algorithms", systemImage: "list.number") }
				.tag(Tab.algorithms)
			
			TrainerScreen()
				.tabItem { Label("Trainer", systemImage: "dial.max") }
				.tag(Tab.trainer)
			
			SettingsScreen(settings: $settings)
				.tabItem { Label("Settings", systemImage: "gear") }
				.tag(Tab.settings)
		}
		.environmentObject(AlgorithmCustomizer())
	}
	
	enum Tab: String {
		case timer
		case algorithms
		case trainer
		case settings
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(settings: .constant(.init()))
	}
}
