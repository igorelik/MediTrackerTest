import Foundation

public final class AuthenticationService: AuthenticationServiceProtocol {
    private let userDefaults: UserDefaults
    private let key = "MediTracker.username"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var isLoggedIn: Bool { !username.isEmpty }
    
    public var username: String {
        userDefaults.string(forKey: key) ?? String()
    }

    public func login(username: String, password: String) async throws {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }

        userDefaults.set(trimmed, forKey: key)
    }
    
    public func logout() async throws {
        userDefaults.set("", forKey: key)
    }

    public enum AuthenticationError: Error {
        case invalidCredentials
    }
}


