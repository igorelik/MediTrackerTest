public class ReminderServicePreview: ReminderServiceProtocol {
    @MainActor
    public func schedule(notification: NotificationEntity, for medication: MedicationEntity) async throws {
    }
    
    @MainActor
    public func cancel(notification: NotificationEntity) async {
    }
}
