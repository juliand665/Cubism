import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			TimerScreen()
				.tabItem { Label("Timer", systemImage: "stopwatch") }
			
			AlgorithmsScreen()
				.tabItem { Label("Algorithms", systemImage: "list.number") }
			
			TrainerScreen()
				.tabItem { Label("Trainer", systemImage: "dial.max") }
			
			Text("TODO")
				.tabItem { Label("Settings", systemImage: "gear") }
		}
		.environmentObject(AlgorithmCustomizer())
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
