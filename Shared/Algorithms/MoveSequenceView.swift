import SwiftUI
import SwiftUIMissingPieces
import Algorithms

struct MoveSequenceView: View {
	var moves: MoveSequence
	
	@State private var width: CGFloat = 100.0
	@ScaledMetric private var boxSize = 40.0
	@ScaledMetric private var boxSpacing = 2.0
	
    var body: some View {
		let spacePerBox = boxSize + boxSpacing
		let boxesPerRow = floor((width + boxSpacing) / spacePerBox)
		let rowSpacing = 4 * boxSpacing
		let rowHeight = boxSize + rowSpacing
		
		return GeometryReader { geometry in
			ForEach(moves.moves.indexed(), id: \.element.id) { index, move in
				let row = index / Int(boxesPerRow)
				let indexInRow = index - row * Int(boxesPerRow)
				let indexOffset = CGFloat(indexInRow) - (boxesPerRow - 1) / 2
				let x = geometry.size.width / 2 + spacePerBox * indexOffset
				let rowOffset = CGFloat(row) * rowHeight
				
				box(for: move)
					.position(x: x, y: rowOffset + boxSize / 2)
			}
		}
		.frame(height: ceil(CGFloat(moves.count) / boxesPerRow) * rowHeight - rowSpacing)
		.measured { width = $0.width }
    }
	
	@ViewBuilder
	func box(for move: Move) -> some View {
		let color = move.target.color
		
		VStack(spacing: 0) {
			let targetBar = VStack(spacing: 1) {
				if case .doubleFace = move.target {
					VStack(spacing: 3) {
						color
						color
					}
				} else {
					color
				}
			}
			.frame(height: 9)
			
			targetBar.opacity(move.direction == .counterclockwise ? 0 : 1)
			
			Text(StandardNotation.description(for: move))
				.font(.subheadline)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.foregroundColor(color)
			
			targetBar.opacity(move.direction == .clockwise ? 0 : 1)
		}
		.background(color.opacity(0.25))
		.frame(width: boxSize, height: boxSize)
		.compositingGroup()
		.mask(RoundedRectangle(cornerRadius: 9, style: .continuous))
	}
}

struct MoveSequenceView_Previews: PreviewProvider {
    static var previews: some View {
		MoveSequenceView(moves: "R U Ri Ui x ri F R Fi y RR d Ri UU R Di Ri uu Ri z L u BB Li xx M EE Si MM Ei S")
			.inEachColorScheme()
			.previewLayout(.fixed(width: 420, height: 320))
			.padding()
    }
}
