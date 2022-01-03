extension CubeTransformation: TextOutputStreamable {
	func write<Target: TextOutputStream>(to target: inout Target) {
		guard self != .zero else {
			print("CubeTransformation.zero", terminator: "", to: &target)
			return
		}
		
		print("CubeTransformation(", to: &target)
		
		if corners.orientation.isFlipped {
			print("\tL-R flipped", to: &target)
		}
		
		let lines = [
			corners.permutation.contentDescription,
			corners.orientation.contentDescription,
			edges.permutation.contentDescription,
			edges.orientation.contentDescription,
		]
		for line in lines where !line.isEmpty {
			print("\t" + line, to: &target)
		}
		
		print(")", terminator: "", to: &target)
	}
}

extension CornerPermutation: CustomStringConvertible {
	var description: String {
		"CornerPermutation(\(contentDescription))"
	}
	
	fileprivate var contentDescription: String {
		Corner.allCases.compactMap {
			let new = self[$0]
			guard new != $0 else { return nil }
			return "\($0.name) ← \(new.name)"
		}.joined(separator: ", ")
	}
}

extension EdgePermutation: CustomStringConvertible {
	var description: String {
		"EdgePermutation(\(contentDescription))"
	}
	
	fileprivate var contentDescription: String {
		Edge.allCases.compactMap {
			let new = self[$0]
			guard new != $0 else { return nil }
			return "\($0.name) ← \(new.name)"
		}.joined(separator: ", ")
	}
}

extension CornerOrientation: CustomStringConvertible {
	var description: String {
		"CornerOrientation(\(contentDescription)\(isFlipped ? ", L-R flipped" : ""))"
	}
	
	fileprivate var contentDescription: String {
		Corner.allCases.compactMap {
			let orientation = self[$0]
			switch orientation {
			case .neutral:
				return nil
			case.twistedCW:
				return "\($0.name): cw"
			case.twistedCCW:
				return "\($0.name): ccw"
			}
		}.joined(separator: ", ")
	}
}

extension EdgeOrientation: CustomStringConvertible {
	var description: String {
		"EdgeOrientation(\(contentDescription))"
	}
	
	fileprivate var contentDescription: String {
		Edge.allCases.compactMap {
			let orientation = self[$0]
			guard orientation != .neutral else { return nil }
			return "\($0.name): flipped"
		}.joined(separator: ", ")
	}
}
