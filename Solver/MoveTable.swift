import Foundation

typealias FaceTurnMoveTable<Coord: Coordinate> = MoveTable<FaceTurnEntry<Coord>>
typealias StandardSymmetryTable<Coord: Coordinate> = MoveTable<StandardSymmetryEntry<Coord>>

struct MoveTable<Entry: MoveTableEntry> {
	var entries: [Entry]
	
	subscript(coord: Entry.Coord) -> Entry {
		entries[coord.intValue]
	}
	
	init() {
		entries = measureTime(
			as: "setup of move table for \(Entry.Coord.self) with \(Entry.Coord.count) \(Entry.self) entries of size \(MemoryLayout<Entry>.size)"
		) {
			(0..<Entry.Coord.count).map {
				Entry(state: Entry.Coord($0).makeState())
			}
		}
	}
}

protocol MoveTableEntry {
	associatedtype Coord: Coordinate
	
	init(state: Coord.CubeState)
}

struct FaceTurnEntry<Coord: Coordinate>: MoveTableEntry {
	var up: FaceMoves
	var down: FaceMoves
	var right: FaceMoves
	var left: FaceMoves
	var front: FaceMoves
	var back: FaceMoves
	
	subscript(move: SolverMove) -> Coord {
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
	
	init(state: Coord.CubeState) {
		up = .init(state: state, face: .up)
		down = .init(state: state, face: .down)
		right = .init(state: state, face: .right)
		left = .init(state: state, face: .left)
		front = .init(state: state, face: .front)
		back = .init(state: state, face: .back)
	}
	
	struct FaceMoves {
		var clockwise: Coord
		var double: Coord
		var counterclockwise: Coord
		
		subscript(direction: Move.Direction) -> Coord {
			switch direction {
			case .clockwise:
				return clockwise
			case .double:
				return double
			case .counterclockwise:
				return counterclockwise
			}
		}
		
		init(state: Coord.CubeState, face: Face) {
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

struct StandardSymmetryEntry<Coord: Coordinate>: MoveTableEntry {
	var moves: [Coord]
	
	init(state: Coord.CubeState) {
		moves = Symmetry.standardSubgroup.map { .init($0.shift(state)) }
	}
}
