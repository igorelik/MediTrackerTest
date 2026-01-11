import Foundation

public final class ConfigurationServicePreview: ConfigurationServiceProtocol {
    public init() {}
    
    public var BaseURI: URL { URL(string: "https://preview.example")! }
    public var APIKey: String { "preview-key" }
}
