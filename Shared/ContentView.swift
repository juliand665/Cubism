import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			TimerScreen()
				.tabItem { Label("Timer", systemImage: "stopwatch") }
			
			AlgorithmsScreen()
				.tabItem { Label("Algorithms", systemImage: "list.number") }
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
