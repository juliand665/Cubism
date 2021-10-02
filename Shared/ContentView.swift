import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			TimerScreen()
				.tabItem { Label("Timer", systemImage: "stopwatch") }
			
			AlgorithmsScreen()
				.tabItem { Label("Algorithms", systemImage: "list.number") }
			
			Text("TODO")
				.tabItem { Label("Settings", systemImage: "gear") }
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
