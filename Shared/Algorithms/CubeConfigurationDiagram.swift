import SwiftUI
import CGeometry
import HandyOperators

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
		let configuration: OLLConfiguration
		
		var body: some View {
			VStack(spacing: spacing) {
				let c = configuration
				
				HStack(spacing: spacing) {
					cornerSpacer
					horizontalTile(isYellow: c.nwCorner == .facingCW)
					horizontalTile(isYellow: !c.correctEdges.contains(.north))
					horizontalTile(isYellow: c.neCorner == .facingCCW)
					cornerSpacer
				}
				HStack(spacing: spacing) {
					verticalTile(isYellow: c.nwCorner == .facingCCW)
					squareTile(isYellow: c.nwCorner == .correct)
					squareTile(isYellow: c.correctEdges.contains(.north))
					squareTile(isYellow: c.neCorner == .correct)
					verticalTile(isYellow: c.neCorner == .facingCW)
				}
				HStack(spacing: spacing) {
					verticalTile(isYellow: !c.correctEdges.contains(.west))
					squareTile(isYellow: c.correctEdges.contains(.west))
					squareTile(isYellow: true)
					squareTile(isYellow: c.correctEdges.contains(.east))
					verticalTile(isYellow: !c.correctEdges.contains(.east))
				}
				HStack(spacing: spacing) {
					verticalTile(isYellow: c.swCorner == .facingCW)
					squareTile(isYellow: c.swCorner == .correct)
					squareTile(isYellow: c.correctEdges.contains(.south))
					squareTile(isYellow: c.seCorner == .correct)
					verticalTile(isYellow: c.seCorner == .facingCCW)
				}
				HStack(spacing: spacing) {
					cornerSpacer
					horizontalTile(isYellow: c.swCorner == .facingCCW)
					horizontalTile(isYellow: !c.correctEdges.contains(.south))
					horizontalTile(isYellow: c.seCorner == .facingCW)
					cornerSpacer
				}
			}
		}
		
		func baseTile(isYellow: Bool) -> some View {
			RoundedRectangle(cornerRadius: _cornerRadius)
				.fill(isYellow ? Color.yellow : Color.gray)
				.opacity(isYellow ? 1 : 0.25)
		}
		
		func squareTile(isYellow: Bool) -> some View {
			baseTile(isYellow: isYellow)
				.frame(width: squareSize, height: squareSize)
		}
		
		func horizontalTile(isYellow: Bool) -> some View {
			baseTile(isYellow: isYellow)
				.frame(width: squareSize, height: edgeSize)
		}
		
		func verticalTile(isYellow: Bool) -> some View {
			baseTile(isYellow: isYellow)
				.frame(width: edgeSize, height: squareSize)
		}
		
		var cornerSpacer: some View {
			Color.clear.frame(width: edgeSize, height: edgeSize)
		}
	}
	
	struct PLLDiagram: View {
		let permutation: PLLPermutation
		
		var body: some View {
			ZStack {
				face
				
				arrows(for: permutation.cornerCycles, getPosition: position(of:))
					.opacity(0.6)
				
				arrows(for: permutation.edgeCycles, getPosition: position(of:))
					.opacity(0.8)
			}
			.foregroundColor(.black)
		}
		
		@ViewBuilder
		var face: some View {
			VStack(spacing: spacing) {
				HStack(spacing: spacing) {
					cornerSpacer
					horizontalTile(color: .orange) // TODO: switch colors based on cycles
					horizontalTile(color: .orange)
					horizontalTile(color: .orange)
					cornerSpacer
				}
				HStack(spacing: spacing) {
					verticalTile(color: .blue)
					squareTile
					squareTile
					squareTile
					verticalTile(color: .green)
				}
				HStack(spacing: spacing) {
					verticalTile(color: .blue)
					squareTile
					squareTile
					squareTile
					verticalTile(color: .green)
				}
				HStack(spacing: spacing) {
					verticalTile(color: .blue)
					squareTile
					squareTile
					squareTile
					verticalTile(color: .green)
				}
				HStack(spacing: spacing) {
					cornerSpacer
					horizontalTile(color: .red)
					horizontalTile(color: .red)
					horizontalTile(color: .red)
					cornerSpacer
				}
			}
		}
		
		func baseTile(color: Color) -> some View {
			RoundedRectangle(cornerRadius: _cornerRadius)
				.fill(color)
		}
		
		var squareTile: some View {
			baseTile(color: .yellow)
				.frame(width: squareSize, height: squareSize)
		}
		
		func horizontalTile(color: Color) -> some View {
			baseTile(color: color)
				.frame(width: squareSize, height: edgeSize)
		}
		
		func verticalTile(color: Color) -> some View {
			baseTile(color: color)
				.frame(width: edgeSize, height: squareSize)
		}
		
		func arrows<Part>(for cycles: [[Part]], getPosition: @escaping (Part) -> Point) -> some View {
			ForEach(static: cycles) { cycle in
				ZStack {
					let positions = cycle.map(getPosition)
					let pairs = Array(zip(positions, positions.dropFirst() + positions))
					let arrowParts = pairs.map(arrowParts)
					
					let strokeStyle = StrokeStyle(lineWidth: arrowWidth, lineCap: .round, lineJoin: .round)
					
					ForEach(static: arrowParts) { base, tip in
						base.stroke(style: strokeStyle)
					}
					
					ForEach(static: arrowParts) { base, tip in
						tip.stroke(style: strokeStyle <- { $0.lineWidth += arrowKnockoutRadius })
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
		
		func arrowParts(from start: Point, to end: Point) -> (line: Path, tip: Path) {
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
		
		func position(of corner: FaceCorner) -> Point {
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
		
		func position(of edge: FaceEdge) -> Point {
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
}

private let squareSize = 16.0
private let edgeSize = 4.0
private let _cornerRadius = 1.0
private let spacing = 1.0
private let arrowTipSize = 8.0
private let arrowWidth = 2.0
private let arrowKnockoutRadius = 2.0

var cornerSpacer: some View {
	Color.clear.frame(width: edgeSize, height: edgeSize)
}

struct CubeConfigurationDiagram_Previews: PreviewProvider {
    static var previews: some View {
		HStack(spacing: 20) {
			CubeConfigurationDiagram(configuration: .oll(.init(
				correctEdges: [.south, .east],
				neCorner: .facingCCW, swCorner: .facingCW, nwCorner: .correct
			)))
			CubeConfigurationDiagram(configuration: Algorithm.tPerm.configuration!)
			CubeConfigurationDiagram(configuration: Algorithm.uPermCW.configuration!)
		}
		.inEachColorScheme()
		.previewInterfaceOrientation(.landscapeLeft)
    }
}
