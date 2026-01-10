import Foundation

public protocol ConfigurationServiceProtocol {
    var BaseURI: URL { get }
    var APIKey: String { get }
}
