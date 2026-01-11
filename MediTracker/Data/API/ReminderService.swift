import Foundation
import UserNotifications

public final class ReminderService: ReminderServiceProtocol {
    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    private func identifier(for notification: NotificationEntity) -> String {
        "notification-\(notification.id.uuidString)"
    }

    @MainActor
    public func cancel(notification: NotificationEntity) async {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: notification)])
    }

    @MainActor
    public func schedule(notification: NotificationEntity, for medication: MedicationEntity) async throws {
        // request authorization if needed
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else { return }

        // build content
        let content = UNMutableNotificationContent()
        content.title = medication.name
        content.body = "Time to take \(medication.name) — \(medication.dosage)"

        var trigger: UNNotificationTrigger?

        switch notification.frequency {
        case .daily:
            if let time = notification.notificationTime {
                let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                var dateComps = DateComponents()
                dateComps.hour = comps.hour
                dateComps.minute = comps.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
            }
        case .twiceDaily:
            if let time = notification.notificationTime {
                let comps = Calendar.current.dateComponents([.hour, .minute], from: time)
                var dateComps = DateComponents()
                dateComps.hour = comps.hour
                dateComps.minute = comps.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: true)
            }
        case .weekly:
            if let weekday = notification.weekday, let time = notification.notificationTime {
                let timeComps = Calendar.current.dateComponents([.hour, .minute], from: time)
                var comps = DateComponents()
                comps.weekday = weekday
                comps.hour = timeComps.hour
                comps.minute = timeComps.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            }
        case .asNeeded:
            if let time = notification.notificationTime {
                let timeComps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
                var comps = DateComponents()
                comps.year = timeComps.year
                comps.month = timeComps.month
                comps.day = timeComps.day
                comps.hour = timeComps.hour
                comps.minute = timeComps.minute
                trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            }
        }

        guard let trig = trigger else { return }
        let req = UNNotificationRequest(identifier: identifier(for: notification), content: content, trigger: trig)
        try await center.add(req)
    }
}
