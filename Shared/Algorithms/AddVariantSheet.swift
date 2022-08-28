import SwiftUI

struct AddVariantSheet: View {
	var algorithm: Algorithm
	var add: (Algorithm.Variant) -> Void
	
	@State var moves = ""
	@State var parsed: Result<MoveSequence, Error> = .success(.init(moves: []))
	@State var configuration: CubeConfiguration?
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		Form {
			configurationDiagram
			
			switch parsed {
			case .success(let sequence):
				MoveSequenceView(moves: sequence)
			case .failure(let error):
				HStack {
					Image(systemName: "xmark.octagon.fill")
					
					VStack(alignment: .leading, spacing: 8) {
						errorDescription(for: error)
					}
				}
				.font(.callout)
				.foregroundColor(.red)
			}
			
			TextField("Enter Moves", text: $moves)
				.onChange(of: moves) { moves in
					withAnimation { updateSequence(moves: moves) }
				}
		}
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel", role: .cancel) { dismiss() }
			}
			ToolbarItem(placement: .confirmationAction) {
				Button("Done") {
					guard case .success(let sequence) = parsed else { return }
					add(Algorithm.Variant(id: .dynamic(.init()), moves: sequence))
					dismiss()
				}
				.disabled(!parsed.isSuccess)
				.disabled((try? parsed.get())?.moves.isEmpty == true)
			}
		}
		.navigationTitle("Add Variant")
		.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	var configurationDiagram: some View {
		if let originalConfiguration = algorithm.configuration {
			HStack {
				Spacer()
				
				VStack {
					CubeConfigurationDiagram(configuration: originalConfiguration, scale: 1.5)
					Text("Original")
				}
				
				if let configuration {
					Spacer()
					
					VStack {
						CubeConfigurationDiagram(configuration: configuration, scale: 1.5)
						Text("Variant")
					}
				}
				
				Spacer()
			}
			.font(.caption)
			.frame(maxWidth: .infinity)
			.padding()
			.alignmentGuide(.compatibleListRowSeparatorLeading) { $0[.leading] }
		}
	}
	
	func updateSequence(moves: String) {
		parsed = .init {
			let sequence = try MoveSequence(parsing: moves)
			configuration = nil
			if let originalConfiguration = algorithm.configuration {
				do {
					let transform = try sequence.transformReversingRotations()
					let new = try originalConfiguration.same(with: transform)
					configuration = new
				} catch TransformationConversionError.notLimitedToULayer {
					throw VerificationError.notLimitedToULayer
				} catch {
					throw VerificationError.couldNotConstructConfiguration
				}
				
				do {
					try originalConfiguration.check(sequence)
				} catch {
					throw VerificationError.doesNotMatchOriginal
				}
			}
			return sequence
		}
	}
	
	@ViewBuilder
	func errorDescription(for error: Error) -> some View {
		switch error {
		case let parseError as NotationParser.ParseError:
			switch parseError {
			case .unknownDirection(let direction):
				Text("Unknown direction: \(direction)")
				Text("expected e.g. R, R2, R', Ri, RR")
				if let _ = try? NotationParser.target(from: direction) {
					Text("Note: moves must be separated by spaces!")
				}
			case .unknownTarget(let target):
				Text("Unknown target: \(String(target))")
				Text("expected e.g. R, u, M, y")
			case .missingWideTurnTarget:
				Text("Missing target for wide turn.")
				Text("expected e.g. 2R, 4Rw")
			}
		case let verificationError as VerificationError:
			switch verificationError {
			case .notLimitedToULayer:
				Text("Variant affects pieces outside U layer.")
			case .couldNotConstructConfiguration:
				Text("Could not construct a configuration from the given sequence.")
				Text("Are you using non-3x3 moves?")
			case .doesNotMatchOriginal:
				Text("Variant result does not match original algorithm!")
				Text("Add y moves before variant to adjust rotation.")
			}
		default:
			Text("Unknown error!")
			Text(error.localizedDescription)
		}
	}
	
	enum VerificationError: Error {
		case notLimitedToULayer
		case couldNotConstructConfiguration
		case doesNotMatchOriginal
	}
}

extension Result {
	var isSuccess: Bool {
		switch self {
		case .success: return true
		case .failure: return false
		}
	}
}

struct AddVariantSheet_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			AddVariantSheet(algorithm: .uPermA) { _ in }
		}
    }
}
