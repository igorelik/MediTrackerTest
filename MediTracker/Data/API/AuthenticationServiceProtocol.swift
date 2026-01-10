import Foundation

public protocol AuthenticationServiceProtocol: AnyObject {
    var username: String { get }
    func login(username: String, password: String) async throws
}
