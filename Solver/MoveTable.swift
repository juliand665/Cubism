typealias FaceTurnMoveTable<Coord: Coordinate> = MoveTable<Coord, SolverMoveMap<Coord>>
typealias StandardSymmetryTable<Coord: Coordinate> = MoveTable<Coord, StandardSymmetryEntry<Coord>>

struct MoveTable<Coord: Coordinate, Entry> {
	var entries: [Entry]
	
	subscript(coord: Coord) -> Entry {
		entries[coord.intValue]
	}
	
	init(computeEntry: (Coord) -> Entry) {
		entries = measureTime(
			as: "setup of move table for \(Coord.self) with \(Coord.count) \(Entry.self) entries of size \(MemoryLayout<Entry>.size)"
		) {
			Coord.allValues.map(computeEntry)
		}
	}
	
	init(for coord: Coord.Type = Coord.self, computeEntry: (Coord.CubeState) -> Entry) {
		self.init { computeEntry($0.makeState()) }
	}
	
	init() where Entry == SolverMoveMap<Coord> {
		self.init { Entry(state: $0.makeState()) }
	}
	
	init() where Entry == StandardSymmetryEntry<Coord> {
		self.init { Entry(state: $0.makeState()) }
	}
}

struct SolverMoveMap<Value> {
	var up: FaceMoves
	var down: FaceMoves
	var right: FaceMoves
	var left: FaceMoves
	var front: FaceMoves
	var back: FaceMoves
	
	subscript(move: SolverMove) -> Value {
		self[move.action]
	}
	
	subscript(action: SolverMove.Action) -> Value {
		self[action.face][action.direction]
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
	
	init(computing mapForFace: (Face) -> FaceMoves) {
		up = mapForFace(.up)
		down = mapForFace(.down)
		right = mapForFace(.right)
		left = mapForFace(.left)
		front = mapForFace(.front)
		back = mapForFace(.back)
	}
	
	init(computing valueForMove: (SolverMove.Action) -> Value) {
		self.init { face in
			FaceMoves { valueForMove(.init(face: face, direction: $0)) }
		}
	}
	
	init(state: Value.CubeState) where Value: Coordinate {
		self.init { .init(state: state, face: $0) }
	}
	
	struct FaceMoves {
		var clockwise: Value
		var double: Value
		var counterclockwise: Value
		
		subscript(direction: Move.Direction) -> Value {
			switch direction {
			case .clockwise:
				return clockwise
			case .double:
				return double
			case .counterclockwise:
				return counterclockwise
			}
		}
	}
}

extension SolverMoveMap.FaceMoves {
	init(computing valueForDirection: (Move.Direction) -> Value) {
		clockwise = valueForDirection(.clockwise)
		double = valueForDirection(.double)
		counterclockwise = valueForDirection(.counterclockwise)
	}
	
	init(state: Value.CubeState, face: Face) where Value: Coordinate {
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

struct StandardSymmetryEntry<Coord: Coordinate> {
	var moves: [Coord]
	
	subscript(symmetry: StandardSymmetry) -> Coord {
		moves[symmetry.index]
	}
}

extension StandardSymmetryEntry {
	init(state: Coord.CubeState) {
		self.init { .init($0.shift(state)) }
	}
	
	init(computing valueForSymmetry: (Symmetry) -> Coord) {
		moves = Symmetry.standardSubgroup.map(valueForSymmetry)
	}
}
