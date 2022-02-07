import SwiftUI

struct ContentView: View {
	var body: some View {
		TabView {
			TimerScreen()
				.tabItem { Label("Timer", systemImage: "stopwatch") }
			
			AlgorithmsScreen()
				.tabItem { Label("Algorithms", systemImage: "list.number") }
			
			TestScreen()
				.tabItem { Label("Testing", systemImage: "testtube.2") }
			
			Text("TODO")
				.tabItem { Label("Settings", systemImage: "gear") }
		}
	}
}

struct TestScreen: View {
	@State var timeTaken: TimeInterval?
	
	var body: some View {
		Button("Time Stuff", action: testPruningTable)
		if let timeTaken = timeTaken {
			Text("Time taken: \(timeTaken) seconds")
		}
	}
	
	func testPruningTable() {
		_ = UDSliceCoordinate.standardSymmetryTable
		_ = EdgeOrientationCoordinate.standardSymmetryTable
		print(ReducedFlipUDSliceCoordinate.count, "representants")
		print()
		_ = ReducedFlipUDSliceCoordinate.moveTable
		
		let start = Date.now
		let table = PruningTable<Phase1Coordinate>()
		_ = table
		timeTaken = -start.timeIntervalSinceNow
		print("done!", table.distances.count, "entries")
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
