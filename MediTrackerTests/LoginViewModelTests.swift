import Foundation
import Testing
@testable import MediTracker

final class MockAuthForLogin: AuthenticationServiceProtocol {
    var username: String = ""
    var isLoggedIn: Bool { !username.isEmpty }
    var willThrow = false

    func login(username: String, password: String) async throws {
        if willThrow { throw NSError(domain: "mock", code: 1) }
        self.username = username
    }

    func logout() async throws { username = "" }
}

struct LoginViewModelTests {

    @Test func loginSucceedsSetsUsername() async throws {
        let mock = MockAuthForLogin()
        let vm = await LoginViewModel(authService: mock)

        try await vm.login(username: "tester", password: "pwd")

        #expect(mock.username == "tester")
        #expect(vm.username == "tester")
    }

    @Test func loginPropagatesError() async throws {
        let mock = MockAuthForLogin()
        mock.willThrow = true
        let vm = await LoginViewModel(authService: mock)

        do {
            try await vm.login(username: "x", password: "y")
            #expect(false)
        } catch {
            #expect(true)
        }
    }
}
