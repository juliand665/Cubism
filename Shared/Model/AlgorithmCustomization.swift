import Foundation
import UserDefault

struct AlgorithmCustomization: Codable {
	var nameOverride: String?
	var preferredVariant: Algorithm.Variant.ID?
	var rotation = 0
	var customVariants: [Algorithm.Variant] = []
}

extension Algorithm {
	func preferredVariant(using customization: AlgorithmCustomization) -> Algorithm.Variant? {
		(variants + customization.customVariants)
			.first { $0.id == customization.preferredVariant }
	}
}

@MainActor
final class AlgorithmCustomizer: ObservableObject {
	@UserDefault("AlgorithmCustomizer.storage")
	private static var storage = Storage()
	
	subscript(id: Algorithm.ID) -> AlgorithmCustomization {
		get {
			Self.storage.customizations[id] ?? .init()
		}
		set {
			objectWillChange.send()
			Self.storage.customizations[id] = newValue
		}
	}
	
	struct Storage: Codable, DefaultsValueConvertible {
		var customizations: [Algorithm.ID: AlgorithmCustomization] = [:]
	}
}
