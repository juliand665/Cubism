import SwiftUI
import CGeometry
import HandyOperators

// using implicit double-cgfloat conversion breaks swiftui previews' bounds display
typealias FloatLiteralType = CGFloat

struct CubeConfigurationDiagram: View {
	let configuration: CubeConfiguration
	
	var body: some View {
		switch configuration {
		case .oll(let configuration):
			OLLDiagram(configuration: configuration)
		case .pll(let permutation):
			PLLDiagram(permutation: permutation)
		}
	}
	
	struct OLLDiagram: View {
		typealias Parts = DiagramParts
		
		let configuration: OLLConfiguration
		
		var body: some View {
			let spacing = DiagramParts.spacing
			VStack(spacing: spacing) {
				let c = configuration
				
				HStack(spacing: spacing) {
					Parts.cornerSpacer
					Parts.horizontalTile(isYellow: c.nwCorner == .facingCW)
					Parts.horizontalTile(isYellow: !c.correctEdges.contains(.north))
					Parts.horizontalTile(isYellow: c.neCorner == .facingCCW)
					Parts.cornerSpacer
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(isYellow: c.nwCorner == .facingCCW)
					Parts.squareTile(isYellow: c.nwCorner == .correct)
					Parts.squareTile(isYellow: c.correctEdges.contains(.north))
					Parts.squareTile(isYellow: c.neCorner == .correct)
					Parts.verticalTile(isYellow: c.neCorner == .facingCW)
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(isYellow: !c.correctEdges.contains(.west))
					Parts.squareTile(isYellow: c.correctEdges.contains(.west))
					Parts.squareTile(isYellow: true)
					Parts.squareTile(isYellow: c.correctEdges.contains(.east))
					Parts.verticalTile(isYellow: !c.correctEdges.contains(.east))
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(isYellow: c.swCorner == .facingCW)
					Parts.squareTile(isYellow: c.swCorner == .correct)
					Parts.squareTile(isYellow: c.correctEdges.contains(.south))
					Parts.squareTile(isYellow: c.seCorner == .correct)
					Parts.verticalTile(isYellow: c.seCorner == .facingCCW)
				}
				HStack(spacing: spacing) {
					Parts.cornerSpacer
					Parts.horizontalTile(isYellow: c.swCorner == .facingCCW)
					Parts.horizontalTile(isYellow: !c.correctEdges.contains(.south))
					Parts.horizontalTile(isYellow: c.seCorner == .facingCW)
					Parts.cornerSpacer
				}
			}
		}
	}
	
	struct PLLDiagram: View {
		typealias Parts = DiagramParts
		
		let permutation: PLLPermutation
		let edges: PLLEdges
		
		init(permutation: PLLPermutation) {
			self.permutation = permutation
			self.edges = .init() <- { $0.apply(permutation) }
		}
		
		var body: some View {
			ZStack {
				face
				
				arrows(for: permutation.cornerCycles, getPosition: DiagramParts.position(of:))
					.opacity(0.6)
				
				arrows(for: permutation.edgeCycles, getPosition: DiagramParts.position(of:))
					.opacity(0.8)
			}
			.foregroundColor(.black)
		}
		
		@ViewBuilder
		var face: some View {
			let spacing = DiagramParts.spacing
			
			VStack(spacing: spacing) {
				HStack(spacing: spacing) {
					Parts.cornerSpacer
					Parts.horizontalTile(color: edges.colors[0])
					Parts.horizontalTile(color: edges.colors[1])
					Parts.horizontalTile(color: edges.colors[2])
					Parts.cornerSpacer
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(color: edges.colors[11])
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.verticalTile(color: edges.colors[3])
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(color: edges.colors[10])
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.verticalTile(color: edges.colors[4])
				}
				HStack(spacing: spacing) {
					Parts.verticalTile(color: edges.colors[9])
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.yellowSquareTile
					Parts.verticalTile(color: edges.colors[5])
				}
				HStack(spacing: spacing) {
					Parts.cornerSpacer
					Parts.horizontalTile(color: edges.colors[8])
					Parts.horizontalTile(color: edges.colors[7])
					Parts.horizontalTile(color: edges.colors[6])
					Parts.cornerSpacer
				}
			}
		}
		
		func arrows<Part>(for cycles: [[Part]], getPosition: @escaping (Part) -> DiagramParts.Point) -> some View {
			ForEach(static: cycles) { cycle in
				ZStack {
					let positions = cycle.map(getPosition)
					let pairs = Array(zip(positions, positions.dropFirst() + positions))
					let arrowParts = pairs.map(DiagramParts.arrowParts)
					
					let strokeStyle = StrokeStyle(lineWidth: DiagramParts.arrowWidth, lineCap: .round, lineJoin: .round)
					
					ForEach(static: arrowParts) { base, tip in
						base.stroke(style: strokeStyle)
					}
					
					ForEach(static: arrowParts) { base, tip in
						tip.stroke(style: strokeStyle <- { $0.lineWidth += DiagramParts.arrowKnockoutRadius })
							.blendMode(.destinationOut)
					}
					
					ForEach(static: arrowParts) { base, tip in
						base.trimmedPath(from: 0.5, to: 1).stroke(style: strokeStyle)
						tip.fill()
						tip.stroke(style: strokeStyle)
					}
				}
				.sizeIndependent()
				.compositingGroup()
				.shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
			}
		}
	}
}

enum DiagramParts {
	static let squareSize = 16.0
	static let edgeSize = 4.0
	static let cornerRadius = 1.0
	static let spacing = 1.0
	static let arrowTipSize = 8.0
	static let arrowWidth = 2.0
	static let arrowKnockoutRadius = 2.0
	
	static var cornerSpacer: some View {
		Color.clear.frame(width: edgeSize, height: edgeSize)
	}
	
	static func baseTile(color: Color?) -> some View {
		RoundedRectangle(cornerRadius: cornerRadius)
			.fill(color ?? .gray)
			.opacity(color == nil ? 0.25 : 1)
	}
	
	static func baseTile(isYellow: Bool) -> some View {
		baseTile(color: isYellow ? .yellow : nil)
	}
	
	static func squareTile(color: Color?) -> some View {
		baseTile(color: color)
			.frame(width: squareSize, height: squareSize)
	}
	
	static func squareTile(isYellow: Bool) -> some View {
		squareTile(color: isYellow ? .yellow : nil)
	}
	
	static var yellowSquareTile: some View {
		squareTile(color: .yellow)
	}
	
	static func horizontalTile(color: Color?) -> some View {
		baseTile(color: color)
			.frame(width: squareSize, height: edgeSize)
	}
	
	static func horizontalTile(isYellow: Bool) -> some View {
		horizontalTile(color: isYellow ? .yellow : nil)
	}
	
	static func verticalTile(color: Color?) -> some View {
		baseTile(color: color)
			.frame(width: edgeSize, height: squareSize)
	}
	
	static func verticalTile(isYellow: Bool) -> some View {
		verticalTile(color: isYellow ? .yellow : nil)
	}
	
	static func arrowParts(from start: Point, to end: Point) -> (line: Path, tip: Path) {
		let scaleFactor = squareSize + spacing
		let startPoint = CGPoint(x: start.x, y: start.y) * scaleFactor
		let endPoint = CGPoint(x: end.x, y: end.y) * scaleFactor
		
		let angle = (endPoint - startPoint).angle
		
		let line = Path {
			$0.move(to: startPoint)
			$0.addLine(to: endPoint)
		}
		let tip = Self.arrowTip.applying(
			.identity
				.translatedBy(x: endPoint.x, y: endPoint.y)
				.rotated(by: angle + .pi / 2)
		)
		return (line, tip)
	}
	
	static let arrowTip = Path {
		let radius = squareSize * 0.2
		$0.move(to: CGPoint(x: 0, y: -radius))
		$0.addLine(to: CGPoint(x: +radius, y: radius))
		$0.addLine(to: CGPoint(x: -radius, y: radius))
		$0.closeSubpath()
	}
	
	static func position(of corner: FaceCorner) -> Point {
		switch corner {
		case .northEast:
			return .init(x: 1, y: -1)
		case .southEast:
			return .init(x: 1, y: 1)
		case .southWest:
			return .init(x: -1, y: 1)
		case .northWest:
			return .init(x: -1, y: -1)
		}
	}
	
	static func position(of edge: FaceEdge) -> Point {
		switch edge {
		case .north:
			return .init(x: 0, y: -1)
		case .east:
			return .init(x: 1, y: 0)
		case .south:
			return .init(x: 0, y: 1)
		case .west:
			return .init(x: -1, y: 0)
		}
	}
	
	struct Point {
		var x, y: Int
	}
}

struct PLLEdges {
	private static let faceColors = [Color.orange, .green, .red, .blue] // NESW
	private static let baseEdgeColors = faceColors.flatMap { repeatElement($0, count: 3) }
	
	var colors = Self.baseEdgeColors
	
	private func index(of edge: FaceEdge) -> Int {
		edge.rawValue * 3 + 1
	}
	
	private func index(of corner: FaceCorner, clockwise: Bool) -> Int {
		(corner.rawValue * 3 + (clockwise ? 3 : 2)) % colors.count
	}
	
	mutating func apply(_ permutation: PLLPermutation) {
		for cycle in permutation.edgeCycles {
			cycleColors(at: cycle.map(index(of:)))
		}
		
		for cycle in permutation.cornerCycles {
			for isClockwise in [false, true] {
				cycleColors(at: cycle.map { index(of: $0, clockwise: isClockwise) })
			}
		}
	}
	
	mutating func cycleColors(at indices: [Int]) {
		guard let first = indices.first else { return }
		var prev = colors[first]
		for index in indices.reversed() {
			swap(&colors[index], &prev)
		}
	}
}

struct CubeConfigurationDiagram_Previews: PreviewProvider {
    static var previews: some View {
		HStack(spacing: 20) {
			CubeConfigurationDiagram(configuration: .oll(.init(
				correctEdges: [.south, .east],
				neCorner: .facingCCW, swCorner: .facingCW, nwCorner: .correct
			)))
			CubeConfigurationDiagram(configuration: Algorithm.tPerm.configuration!)
			CubeConfigurationDiagram(configuration: Algorithm.uPermB.configuration!)
			CubeConfigurationDiagram(configuration: Algorithm.gPermA.configuration!)
		}
		.inEachColorScheme()
		.previewInterfaceOrientation(.landscapeLeft)
    }
}
