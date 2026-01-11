import Foundation

@Observable
final class LoginViewModel {
    private let authService: AuthenticationServiceProtocol
    
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
    }

    func login(username: String, password: String) async throws {
        _ = try await authService.login(username: username, password: password)
    }
    
    var username: String {
        authService.username
    }
}
