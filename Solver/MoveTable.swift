import Foundation

typealias FaceTurnMoveTable<Space: CoordinateSpace> = MoveTable<FaceTurnEntry<Space>>
typealias StandardSymmetryTable<Space: CoordinateSpace> = MoveTable<StandardSymmetryEntry<Space>>

struct MoveTable<Entry: MoveTableEntry> {
	var entries: [Entry]
	
	subscript(coord: Entry.Space.Coord) -> Entry {
		entries[coord.intValue]
	}
	
	init() {
		entries = (0..<Entry.Space.count).map {
			Entry(state: Entry.Space.Coord($0).makeState())
		}
	}
}

protocol MoveTableEntry {
	associatedtype Space: CoordinateSpace
	
	init(state: Space.CubeState)
}

struct FaceTurnEntry<Space: CoordinateSpace>: MoveTableEntry {
	var up: FaceMoves
	var down: FaceMoves
	var right: FaceMoves
	var left: FaceMoves
	var front: FaceMoves
	var back: FaceMoves
	
	init(state: Space.CubeState) {
		up = .init(state: state, face: .up)
		down = .init(state: state, face: .down)
		right = .init(state: state, face: .right)
		left = .init(state: state, face: .left)
		front = .init(state: state, face: .front)
		back = .init(state: state, face: .back)
	}
	
	struct FaceMoves {
		var clockwise: Space.Coord
		var double: Space.Coord
		var counterclockwise: Space.Coord
		
		init(state: Space.CubeState, face: Face) {
			let transform = CubeTransformation.transform(for: face)
			var state = state
			state += transform
			clockwise = .init(state)
			state += transform
			double = .init(state)
			state += transform
			counterclockwise = .init(state)
		}
	}
}

struct StandardSymmetryEntry<Space: CoordinateSpace>: MoveTableEntry {
	var moves: [Space.Coord]
	
	init(state: Space.CubeState) {
		moves = Symmetry.standardSubgroup.map { .init(state + $0) }
	}
}
