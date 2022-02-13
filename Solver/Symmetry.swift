struct Symmetry {
	/// collection of symmetries that keep the UD slice in its place
	static let standardSubgroup = subgroup(generatedBy: [
		Generator.u4.transforms,
		Generator.f2.transforms,
		Generator.lr2.transforms,
	])
	
	/// collection of symmetries that don't affect edge orientation
	static let edgeFlipPreservingSubgroup = subgroup(generatedBy: [
		[Generator.u4.transforms[0], Generator.u4.transforms[2]],
		Generator.f2.transforms,
		Generator.lr2.transforms,
	])
	
	private static func subgroup(generatedBy transforms: [[CubeTransformation]]) -> [Self] {
		subgroupTransforms(generatedBy: transforms[...]).map(Self.init)
	}
	
	/// last transform is the "outermost" one, like the MSB of a binary number
	private static func subgroupTransforms(
		generatedBy transforms: ArraySlice<[CubeTransformation]>
	) -> [CubeTransformation] {
		guard let first = transforms.first else { return [.zero] }
		return subgroupTransforms(generatedBy: transforms.dropFirst())
			.flatMap { outer in first.map { outer + $0 } }
	}
	
	var forward, backward: CubeTransformation
	
	var inverse: Self { .init(forward: backward, backward: forward) }
	
	func shift<State: PartialCubeState>(_ transform: State) -> State {
		forward + transform + backward
	}
	
	func unshift<State: PartialCubeState>(_ transform: State) -> State {
		backward + transform + forward
	}
	
	struct Generator {
		/// 120° rotation through URF corner
		static let urf3 = Self(name: "URF3", transform: .symmetryURF3)
		
		/// 180° rotation through F face
		static let f2 = Self(name: "F2", transform: .symmetryF2)
		
		/// 90° rotation through U face
		static let u4 = Self(name: "U4", transform: .symmetryU4)
		
		/// left-right flip
		static let lr2 = Self(name: "LR2", transform: .symmetryLR2)
		
		var name: String
		var transforms: [CubeTransformation]
		
		init(name: String, transform: CubeTransformation) {
			self.name = name
			self.transforms = [.zero] + transform.uniqueApplications()
		}
	}
}

extension Symmetry {
	init(forward: CubeTransformation) {
		self.forward = forward
		self.backward = -forward
	}
}

struct StandardSymmetry: Hashable {
	private static let symmetries = Symmetry.standardSubgroup
	static let count = symmetries.count
	static let all: [Self] = symmetries.indices.map(Self.init)
	static let inverses: [Self] = symmetries.map { original in
		Self(index: symmetries.firstIndex { $0.forward == original.backward }!)
	}
	static let compositions: [[Self]] = symmetries.map { first in
		symmetries.map { second in
			let composed = first.forward + second.forward
			return Self(index: symmetries.firstIndex { $0.forward == composed }!)
		}
	}
	static let shiftedMoves: [SolverMoveMap<SolverMove>] = all.map { symmetry in
		let resolved = symmetry.resolved
		return SolverMoveMap { (action: SolverMove.Action) in
			SolverMove.byTransform[resolved.shift(action.resolved.transform)]!
		}
	}
	static let zero = Self(index: 0)
	
	var storedIndex: UInt8
	var index: Int { Int(storedIndex) }
	
	var resolved: Symmetry {
		.standardSubgroup[index]
	}
	
	var inverse: Self {
		Self.inverses[index]
	}
	
	/// shifting with `rhs` then `lhs` is the same as shifting with a different symmetry `lhs * rhs`
	static func * (lhs: Self, rhs: Self) -> Self {
		compositions[lhs.index][rhs.index]
	}
	
	func shift(_ move: SolverMove) -> SolverMove {
		Self.shiftedMoves[index][move]
	}
}

extension StandardSymmetry {
	init(index: Int) {
		assert(Self.symmetries.indices.contains(index))
		self.init(storedIndex: UInt8(index))
	}
}

extension StandardSymmetry: CustomStringConvertible {
	var description: String {
		"S\(storedIndex)"
	}
}
