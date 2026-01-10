import Foundation

public final class ConfigurationService: ConfigurationServiceProtocol {
    public init() {}

    // Hard-coded configuration values for runtime
    public var BaseURI: URL { URL(string: "https://api-jictu6k26a-uc.a.run.app")! }
    public var APIKey: String { "healthengine-mobile-test-2026" }
    public var DefaultUserName: String { "test-user" }
}
