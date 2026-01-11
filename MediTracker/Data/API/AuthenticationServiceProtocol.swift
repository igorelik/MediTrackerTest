import Foundation

public protocol AuthenticationServiceProtocol: AnyObject {
    var username: String { get }
    var isLoggedIn: Bool { get }
    func login(username: String, password: String) async throws
    func logout() async throws
}
