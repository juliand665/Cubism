import Foundation
import UserDefault

struct AlgorithmCustomization: Codable {
	var nameOverride: String?
	var preferredVariant: Algorithm.Variant.ID?
	var rotation = 0
	var customVariants: [Algorithm.Variant] = []
	var tags: Set<Tag> = []
}

struct Tag: Codable, Hashable, Identifiable {
	static let learning = Self(name: "Learning", id: .builtIn("learning"))
	static let known = Self(name: "Known", id: .builtIn("known"))
	
	static let predefinedTags = [learning, known]
	
	var name: String
	var id: ExtensibleID<Self>
}

extension Algorithm {
	func preferredVariant(using customization: AlgorithmCustomization) -> Variant {
		(variants + customization.customVariants)
			.first { $0.id == customization.preferredVariant }
			?? variants.first!
	}
	
	func variantInfo(using customization: AlgorithmCustomization) -> (Variant, CubeConfiguration?) {
		let variant = preferredVariant(using: customization)
		let configuration = configuration.map {
			$0.rotated(by: variant.moves.rotation)
		}
		return (variant, configuration)
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
	
	var userDefinedTags: [Tag] {
		get {
			Self.storage.userDefinedTags
		}
		set {
			objectWillChange.send()
			Self.storage.userDefinedTags = newValue
		}
	}
	
	var allTags: [Tag] { Tag.predefinedTags + userDefinedTags }
	
	struct Storage: Codable, DefaultsValueConvertible {
		var customizations: [Algorithm.ID: AlgorithmCustomization] = [:]
		var userDefinedTags: [Tag] = []
	}
}
