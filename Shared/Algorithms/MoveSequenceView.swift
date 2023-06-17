import SwiftUI
import SwiftUIMissingPieces
import Algorithms
import CGeometry
import HandyOperators

struct MoveSequenceView: View {
	var moves: MoveSequence
	var notationOverride: NotationPreference?
	
	@Environment(\.settings.notation) private var defaultNotation
	@Environment(\.multilineTextAlignment) private var alignment
	
	@ScaledMetric private var boxSize: CGFloat = 40
	@ScaledMetric private var xSpacing: CGFloat = 2
	@ScaledMetric private var ySpacing: CGFloat = 8
	
	private var notation: any Notation.Type {
		(notationOverride ?? defaultNotation).notation
	}
	
	var body: some View {
		MoveLayout(
			alignment: alignment,
			boxSize: boxSize, xSpacing: xSpacing, ySpacing: ySpacing
		) {
			ForEach(moves.moves.indexed(), id: \.element.id) { index, move in
				box(for: move)
			}
		}
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
		.compositingGroup()
		.mask(RoundedRectangle(cornerRadius: 9, style: .continuous))
	}
	
	struct MoveLayout: Layout {
		var alignment: TextAlignment
		
		var boxSize: CGFloat
		var xSpacing: CGFloat
		var ySpacing: CGFloat
		
		var spacing: CGSize {
			.init(width: xSpacing, height: ySpacing)
		}
		
		var xStride: CGFloat { boxSize + xSpacing }
		var yStride: CGFloat { boxSize + ySpacing }
		
		var stride: CGSize {
			.init(width: xStride, height: yStride)
		}
		
		func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
			gridSize(
				width: proposal.width == 0 ? nil : proposal.width,
				boxCount: subviews.count
			) * stride - spacing
		}
		
		func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
			let grid = gridSize(width: bounds.width, boxCount: subviews.count)
			let cols = Int(grid.width)
			let rows = Int(grid.height)
			let lastRowOffset = CGFloat(cols - 1 - (subviews.count - 1) % cols) * alignment.factor
			
			let subviewProposal = ProposedViewSize(width: boxSize, height: boxSize)
			
			for (index, subview) in subviews.enumerated() {
				var pos = CGPoint(x: index % cols, y: index / cols)
				if index / cols == rows - 1 {
					pos.x += lastRowOffset
				}
				pos *= stride
				pos += CGVector(bounds.origin)
				subview.place(at: pos, anchor: .topLeading, proposal: subviewProposal)
			}
		}
		
		func gridSize(width: CGFloat?, boxCount: Int) -> CGSize {
			let count = CGFloat(boxCount)
			let width = width.map { width in
				floor((width + xSpacing) / (boxSize + xSpacing))
			} ?? count
			return .init(
				width: width,
				height: ceil(count / width)
			) <- { print($0) }
		}
	}
}

private extension TextAlignment {
	var factor: CGFloat {
		switch self {
		case .leading:
			return 0.0
		case .center:
			return 0.5
		case .trailing:
			return 1.0
		}
	}
}

struct MoveSequenceView_Previews: PreviewProvider {
	static var previews: some View {
		VStack {
			MoveSequenceView(moves: "R U Ri Ui x ri F R Fi y RR d Ri UU R Di Ri uu Ri z L u BB Li xx M EE Si MM Ei S Rw 3Fw2 4L 2DD")
			Divider()
			Divider()
			let sequence: MoveSequence = "Ui FF RR DD LL D LL D L Fi Di F D Li RR FF"
			MoveSequenceView(moves: sequence)
				.multilineTextAlignment(.leading)
			Divider()
			MoveSequenceView(moves: sequence)
				.multilineTextAlignment(.center)
			Divider()
			MoveSequenceView(moves: sequence)
				.multilineTextAlignment(.trailing)
		}
		.padding()
	}
}
