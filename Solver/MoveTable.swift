import Foundation

typealias FaceTurnMoveTable<Space: CoordinateSpace> = MoveTable<FaceTurnEntry<Space>>
typealias StandardSymmetryTable<Space: CoordinateSpace> = MoveTable<StandardSymmetryEntry<Space>>

struct MoveTable<Entry: MoveTableEntry> {
	var entries: [Entry]
	
	subscript(coord: Entry.Space.Coord) -> Entry {
		entries[coord.intValue]
	}
	
	init() {
		entries = measureTime(
			as: "setup of move table for \(Entry.Space.self) with \(Entry.Space.count) entries of size \(MemoryLayout<Entry>.size)"
		) {
			(0..<Entry.Space.count).map {
				Entry(state: Entry.Space.Coord($0).makeState())
			}
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
	
	subscript(move: SolverMove) -> Space.Coord {
		self[move.face][move.direction]
	}
	
	subscript(face: Face) -> FaceMoves {
		switch face {
		case .front:
			return front
		case .back:
			return back
		case .up:
			return up
		case .down:
			return down
		case .left:
			return left
		case .right:
			return right
		}
	}
	
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
		
		subscript(direction: Move.Direction) -> Space.Coord {
			switch direction {
			case .clockwise:
				return clockwise
			case .double:
				return double
			case .counterclockwise:
				return counterclockwise
			}
		}
		
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
