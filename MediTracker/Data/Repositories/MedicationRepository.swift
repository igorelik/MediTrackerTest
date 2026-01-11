import Foundation
import SwiftData

public final class MedicationRepository: MedicationRepositoryProtocol {

    private let service: MedicationServiceProtocol
    private let authService: AuthenticationServiceProtocol
    private let reminderService: ReminderServiceProtocol
    private let context: ModelContext
 
    public init(service: MedicationServiceProtocol,
                authService: AuthenticationServiceProtocol,
                reminderService: ReminderServiceProtocol,
                context: ModelContext) {
        self.service = service
        self.context = context
        self.authService = authService
        self.reminderService = reminderService
    }

    public func medications() -> [MedicationEntity] {
        let descriptor = FetchDescriptor<MedicationEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let meds = (try? context.fetch(descriptor)) ?? []
        meds.forEach { medication in
            let medicationId = medication.id
            let notifDesc = FetchDescriptor<NotificationEntity>(predicate: #Predicate { $0.medicationId == medicationId })
            let notifications = (try? context.fetch(notifDesc)) ?? []
            if let n1 = notifications.first {
                medication.notification1 = n1
            }
            if notifications.count > 1, let n2 = notifications.last {
                medication.notification2 = n2
            }
        }
        return meds
    }

    public func refresh() async throws {
        let remote = try await service.fetchMedications(username: authService.username)

        // add or update local items based on the remote
        for item in remote {
            upsert(item.toEntity())
        }

        // if medication was removed from the backend, remove local items deleted from the remote and cancel notifications
        for item in medications() where !remote.contains(where: { $0.id == item.id }) {
            let medicationid = item.id
            await cancelMedicationNotificationsByMedicationId(medicationid)
            context.delete(item)
        }

        try context.save()
    }

    public func create(
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        remindersEnabled: Bool,
        reminderTime1: Date?,
        reminderTime2: Date?,
        reminderWeekday: Int?,
        reminderWeekdayTime: Date?,
        reminderAsNeededDate: Date?
    ) async throws {

        let dto = try await service.create(
            username: authService.username,
            name: name,
            dosage: dosage,
            frequency: frequency
        )

        let entity = dto.toEntity()
        context.insert(entity)
        try context.save()

        // handle notifications via NotificationEntity records
        if remindersEnabled {
            // create notification entities depending on frequency
            if frequency == .daily {
                let notif = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: reminderTime1, weekday: nil, createdAt: Date(), updatedAt: Date())
                context.insert(notif)
                try context.save()
                try await reminderService.schedule(notification: notif, for: entity)
            } else if frequency == .twiceDaily {
                if let t1 = reminderTime1 {
                    let n1 = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: t1, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n1)
                    try context.save()
                    try await reminderService.schedule(notification: n1, for: entity)
                }
                if let t2 = reminderTime2 {
                    let n2 = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: t2, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n2)
                    try context.save()
                    try await reminderService.schedule(notification: n2, for: entity)
                }
            } else if frequency == .weekly {
                if let wd = reminderWeekday, let time = reminderWeekdayTime {
                    let n = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: time, weekday: wd, createdAt: Date(), updatedAt: Date())
                    context.insert(n)
                    try context.save()
                    try await reminderService.schedule(notification: n, for: entity)
                }
            }
            else if frequency == .asNeeded {
                if let time = reminderAsNeededDate {
                    let n = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: time, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n)
                    try context.save()
                    try await reminderService.schedule(notification: n, for: entity)
                }
            }
        }
    }

    fileprivate func cancelMedicationNotificationsByMedicationId(_ id: UUID) async {
        // remove existing notifications for this medication
        let notifDesc = FetchDescriptor<NotificationEntity>(predicate: #Predicate { $0.medicationId == id })
        let existingNotifs = (try? context.fetch(notifDesc)) ?? []
        for n in existingNotifs {
            await reminderService.cancel(notification: n)
            context.delete(n)
        }
    }
    
    @MainActor
    public func update(
        entity: MedicationEntity,
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        remindersEnabled: Bool,
        reminderTime1: Date?,
        reminderTime2: Date?,
        reminderWeekday: Int?,
        reminderWeekdayTime: Date?,
        reminderAsNeededDate: Date?
    ) async throws {

        let dto = try await service.update(
            username: entity.username,
            id: entity.id,
            name: name,
            dosage: dosage,
            frequency: frequency
        )

        entity.name = dto.name
        entity.dosage = dto.dosage
        entity.frequency = MedicationFrequency(rawValue: dto.frequency)!
        entity.updatedAt = dto.updatedAt

        try context.save()

        let id = entity.id
        await cancelMedicationNotificationsByMedicationId(id)

        try context.save()

        // create new notifications if enabled
        if remindersEnabled {
            if frequency == .daily {
                let notif = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: reminderTime1, weekday: nil, createdAt: Date(), updatedAt: Date())
                context.insert(notif)
                try context.save()
                try await reminderService.schedule(notification: notif, for: entity)
            } else if frequency == .twiceDaily {
                if let t1 = reminderTime1 {
                    let n1 = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: t1, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n1)
                    try context.save()
                    try await reminderService.schedule(notification: n1, for: entity)
                }
                if let t2 = reminderTime2 {
                    let n2 = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: t2, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n2)
                    try context.save()
                    try await reminderService.schedule(notification: n2, for: entity)
                }
            } else if frequency == .weekly {
                if let wd = reminderWeekday, let time = reminderWeekdayTime {
                    let n = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: time, weekday: wd, createdAt: Date(), updatedAt: Date())
                    context.insert(n)
                    try context.save()
                    try await reminderService.schedule(notification: n, for: entity)
                }
            }
            else if frequency == .asNeeded {
                if let time = reminderAsNeededDate {
                    let n = NotificationEntity(id: UUID(), medicationId: entity.id, frequency: frequency, notificationTime: time, weekday: nil, createdAt: Date(), updatedAt: Date())
                    context.insert(n)
                    try context.save()
                    try await reminderService.schedule(notification: n, for: entity)
                }
            }
        }
    }

    @MainActor
    public func delete(entity: MedicationEntity) async throws {
        try await service.delete(
            username: entity.username,
            id: entity.id
        )

        let id = entity.id
        // cancel and remove notification entities
        let notifDesc = FetchDescriptor<NotificationEntity>(predicate: #Predicate { $0.medicationId == id })
        let existingNotifs = (try? context.fetch(notifDesc)) ?? []
        for n in existingNotifs {
            await reminderService.cancel(notification: n)
            context.delete(n)
        }

        context.delete(entity)
        try context.save()
    }
    
    private func upsert(_ medication: MedicationEntity) {
        if let existing = medications().first(where: { $0.id == medication.id }) {
            existing.name = medication.name
            existing.dosage = medication.dosage
            existing.frequency = medication.frequency
            existing.updatedAt = medication.updatedAt
        } else {
            context.insert(
                MedicationEntity(
                    id: medication.id,
                    username: medication.username,
                    name: medication.name,
                    dosage: medication.dosage,
                    frequency: medication.frequency,
                    createdAt: medication.createdAt,
                    updatedAt: medication.updatedAt
                )
            )
        }
    }
}

