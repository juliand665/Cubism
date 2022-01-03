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

struct StandardSymmetry {
	var index: UInt8
}

extension StandardSymmetry {
	init(index: Int) {
		self.init(index: UInt8(index))
	}
}
