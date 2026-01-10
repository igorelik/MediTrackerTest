import Foundation

public final class AuthenticationServicePreview: AuthenticationServiceProtocol {
    private var stored: String? = "preview-user"
    public init() {}

    public var username: String { stored }

    public func login(username: String, password: String) async throws {
        // accept any non-empty credentials in preview
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            throw AuthenticationService.AuthenticationError.invalidCredentials
        }
        stored = trimmed
    }
}
