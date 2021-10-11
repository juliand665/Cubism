import Foundation

protocol CubePiece: Comparable, CaseIterable {
	var name: String { get }
}

enum Corner: CubePiece, Comparable, CaseIterable {
	case urf, ufl, ulb, ubr
	case dfr, dlf, dbl, drb
	
	var name: String {
		String(describing: self).uppercased()
	}
}

enum Edge: CubePiece, Comparable, CaseIterable {
	case ur, uf, ul, ub
	case dr, df, dl, db
	case fr, fl, bl, br
	
	var name: String {
		String(describing: self).uppercased()
	}
}

protocol PartialCubeState: AdditiveArithmeticWithNegation {
	static func + (state: Self, transform: CubeTransformation) -> Self
	static func += (state: inout Self, transform: CubeTransformation)
}

extension PartialCubeState {
	static func += (state: inout Self, transform: CubeTransformation) {
		state = state + transform
	}
}

struct SolverMove {
	static let all = Face.allCases.flatMap { face -> [Self] in
		let transform = CubeTransformation.transform(for: face)
		let variants = sequence(first: transform) { $0 + transform }
		return zip(Move.Direction.inCWOrder, variants).map { direction, transform in
			Self(
				move: .init(target: .singleFace(face), direction: direction),
				transform: transform
			)
		}
	}
	
	var move: Move
	var transform: CubeTransformation
}

struct Symmetry {
	/// 120° rotation through URF corner
	static let urf3 = Self(name: "URF3", transform: .symmetryURF3)
	
	/// 180° rotation through F face
	static let f2 = Self(name: "F2", transform: .symmetryF2)
	
	/// 90° rotation through U face
	static let u4 = Self(name: "U4", transform: .symmetryU4)
	
	/* not implemented:
	/// left-right flip
	static let lr2 = Self(name: "LR2", transform: .symmetryLR2)
	*/
	
	/// collection of symmetries that keep the UD slice in its place
	static let standardSubgroup = subgroup(generatedBy: [f2.transforms, u4.transforms])
	
	/// collection of symmetries that don't affect edge orientation
	static let edgeFlipPreservingSubgroup = subgroup(generatedBy: [
		f2.transforms,
		[u4.transforms[0], u4.transforms[2]],
	])
	
	private static func subgroup<Transforms: Collection>(
		generatedBy transforms: Transforms
	) -> [CubeTransformation] where
		Transforms.Element == [CubeTransformation]
	{
		guard let first = transforms.first else { return [.zero] }
		return subgroup(generatedBy: transforms.dropFirst())
			.flatMap { outer in first.map { outer + $0 } }
	}
	
	var name: String
	var transforms: [CubeTransformation]
	
	init(name: String, transform: CubeTransformation) {
		self.name = name
		self.transforms = [.zero] + transform.uniqueApplications()
	}
}
