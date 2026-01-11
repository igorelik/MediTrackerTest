import Foundation
import Testing
@testable import MediTracker

struct NotificationPermissionServiceTests {

    @Test func previewAlwaysGrants() async throws {
        let svc = NotificationPermissionServicePreview()
        var granted = false
        let exp = AsyncExpectation()
        svc.requestAuthorization { g in
            granted = g
            exp.fulfill()
        }
        await exp.wait(timeout: 1.0)
        #expect(granted == true)
    }
}
