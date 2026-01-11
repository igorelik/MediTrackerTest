import Foundation
import SwiftData

@Model
public final class NotificationEntity {
    @Attribute(.unique) public var id: UUID
    var medicationId: UUID
    var frequencyRaw: String
    var notificationTime: Date?
    var weekday: Int?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        medicationId: UUID,
        frequency: MedicationFrequency,
        notificationTime: Date? = nil,
        weekday: Int? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.medicationId = medicationId
        self.frequencyRaw = frequency.rawValue
        self.notificationTime = notificationTime
        self.weekday = weekday
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var frequency: MedicationFrequency {
        get { MedicationFrequency(rawValue: frequencyRaw)! }
        set { frequencyRaw = newValue.rawValue }
    }
}
