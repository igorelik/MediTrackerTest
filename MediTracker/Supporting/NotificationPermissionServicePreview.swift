import Foundation
import UserNotifications

public final class NotificationPermissionServicePreview: NotificationPermissionServiceProtocol {
    public init() {}

    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Always grant in previews
        completion(true)
    }

    public func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        completion(.authorized)
    }
}
