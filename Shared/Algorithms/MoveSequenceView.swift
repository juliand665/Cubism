import SwiftUI
import SwiftUIMissingPieces
import Algorithms

infix operator %%: MultiplicationPrecedence

extension BinaryInteger {
	/// true modulo
	static func %% (dividend: Self, divisor: Self) -> Self {
		let remainder = dividend % divisor
		return remainder >= 0 ? remainder : remainder + divisor
	}
}

struct MoveSequenceView: View {
	var moves: MoveSequence
	var anchor: UnitPoint = .center
	var notationOverride: NotationPreference?
	
	@State private var width: CGFloat = 100.0
	@ScaledMetric private var boxSize = 40.0
	@ScaledMetric private var boxSpacing = 2.0
	
	@Environment(\.settings.notation) private var defaultNotation
	
	private var notation: any Notation.Type {
		(notationOverride ?? defaultNotation).notation
	}
	
    var body: some View {
		let spacePerBox = boxSize + boxSpacing
		let boxesPerRow = Int(floor((width + boxSpacing) / spacePerBox))
		let rowCount = (moves.count - 1) / boxesPerRow + 1 // ceil
		let rowSpacing = 4 * boxSpacing
		let rowHeight = boxSize + rowSpacing
		let rowWidth = spacePerBox * CGFloat(boxesPerRow) - boxSpacing
		let xSpace = width - rowWidth
		let emptySpotsInLastRow = -moves.count %% boxesPerRow
		
		return GeometryReader { geometry in
			ForEach(moves.moves.indexed(), id: \.element.id) { index, move in
				let row = index / boxesPerRow
				let indexInRow = index - row * boxesPerRow
				let isInLastRow = row == rowCount - 1
				let extraSpace = isInLastRow ? CGFloat(emptySpotsInLastRow) * anchor.x : 0
				let indexOffset = CGFloat(indexInRow) + extraSpace
				let x = spacePerBox * indexOffset + xSpace * anchor.x
				let y = CGFloat(row) * rowHeight
				
				box(for: move)
					.offset(x: x, y: y)
			}
		}
		.frame(height: max(0, CGFloat(rowCount) * rowHeight - rowSpacing))
		.measured { width = $0.width }
    }
	
	@ViewBuilder
	func box(for move: Move) -> some View {
		let color = move.target.color
		
		VStack(spacing: 0) {
			let targetBar = VStack(spacing: 1) {
				if move.target.hasMultipleLayers {
					Rectangle()
					Rectangle()
				} else if case .bigSlice = move.target {
					Color.clear
					Rectangle()
				} else {
					Rectangle()
				}
			}
			.frame(height: 9)
			.foregroundColor(color)
			
			targetBar.opacity(move.direction == .counterclockwise ? 0 : 1)
			
			Text(notation.description(for: move))
				.font(.subheadline)
				.fontWeight(.medium)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.foregroundColor(increasingContrastOf: color, by: 0.05)
				.padding(.horizontal, -2) // e.g. 3Bw2 is a valid move that's just too long otherwise
			
			targetBar.opacity(move.direction == .clockwise ? 0 : 1).scaleEffect(y: -1)
		}
		.background(color.opacity(0.25))
		.frame(width: boxSize, height: boxSize)
		.compositingGroup()
		.mask(RoundedRectangle(cornerRadius: 9, style: .continuous))
	}
}

struct MoveSequenceView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			MoveSequenceView(moves: "R U Ri Ui x ri F R Fi y RR d Ri UU R Di Ri uu Ri z L u BB Li xx M EE Si MM Ei S Rw 3Fw2 4L 2DD")
			Divider()
			Divider()
			let sequence: MoveSequence = "R U Ri Ui Ri F RR Ui Ri Ui R U Ri Fi"
			MoveSequenceView(moves: sequence, anchor: .leading)
			Divider()
			MoveSequenceView(moves: sequence, anchor: .center)
			Divider()
			MoveSequenceView(moves: sequence, anchor: .trailing)
		}
		.padding()
    }
}
