import Foundation
import UserNotifications

public protocol ReminderServiceProtocol: AnyObject {
    func schedule(notification: NotificationEntity, for medication: MedicationEntity) async throws
    func cancel(notification: NotificationEntity) async
}
