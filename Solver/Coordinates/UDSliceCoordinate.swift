import HandyOperators

/// Describes where the 4 edges belonging in the UD slice are currently, ignoring order.
struct UDSliceCoordinate: CoordinateWithSymmetryTable {
	typealias CubeState = EdgePermutation
	
	static let count: UInt16 = 495 // nCr(12, 8)
	
	static let standardSymmetryTable = StandardSymmetryTable<Self>()
	
	var value: UInt16
}

extension UDSliceCoordinate {
	init(_ state: EdgePermutation) {
		self = state.udSliceCoordinate()
	}
	
	func makeState() -> EdgePermutation {
		.init(self)
	}
}

extension EdgePermutation {
	private static let canonicalOrder = Self().asArray()
	
	init(_ coordinate: UDSliceCoordinate) {
		var currentValue = UInt(UDSliceCoordinate.count)
		// avoid hard math by just trying all possible values until it works lol
		// TODO: make sure this is not called in performance-critical sections…
		for i1 in 3..<12 {
			for i2 in 2..<i1 {
				for i3 in 1..<i2 {
					for i4 in 0..<i3 {
						currentValue -= 1
						guard currentValue == coordinate.value else { continue }
						
						self.init(array: Self.canonicalOrder <- {
							$0.swapAt(i4, 8)
							$0.swapAt(i3, 9)
							$0.swapAt(i2, 10)
							$0.swapAt(i1, 11)
						})
						return
					}
				}
			}
		}
		fatalError("UD slice coordinate out of range")
	}
	
	func udSliceCoordinate() -> UDSliceCoordinate {
		let reduced = asArray()
			.lazy
			.enumerated()
			.reduce(into: (sum: 0, coefficient: 0, k: -1)) { state, new in
				// a complex-looking way to improve performance by avoiding lots of factorial calculations and counting occupied spots in the process
				let edge = new.element
				let n = new.offset
				
				state.coefficient *= n
				if edge.isPartOfUDSlice {
					state.k += 1
					if state.k == 0 {
						state.coefficient = 1
					} else {
						state.coefficient /= state.k
					}
				} else {
					state.coefficient /= n - state.k
					
					if state.k >= 0 {
						state.sum += state.coefficient
					}
				}
			}
		
		assert(reduced.coefficient == 165) // nCr(11, 3)
		assert(reduced.k == 3)
		return .init(reduced.sum)
	}
}
