import SwiftUI
import UserDefault

struct AppSettings {
	@UserDefault("AppSettings.notation")
	var notation: NotationPreference = .standard
}

enum NotationPreference: Codable, DefaultsValueConvertible, Hashable, CaseIterable {
	case standard
	case classic
	
	var notation: any Notation.Type {
		switch self {
		case .standard:
			return StandardNotation.self
		case .classic:
			return NaturalNotation.self
		}
	}
}

extension EnvironmentValues {
	var settings: AppSettings {
		get { self[SettingsKey.self] }
		set { self[SettingsKey.self] = newValue }
	}
	
	private enum SettingsKey: EnvironmentKey {
		static let defaultValue = AppSettings()
	}
}
