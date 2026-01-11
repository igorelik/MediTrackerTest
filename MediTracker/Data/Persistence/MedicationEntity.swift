import Foundation
import SwiftData


@Model
public final class MedicationEntity {
    @Attribute(.unique) public var id: UUID
    var username: String
    var name: String
    var dosage: String
    var frequencyRaw: String
    var createdAt: Date
    var updatedAt: Date
    var notification1: NotificationEntity?
    var notification2: NotificationEntity?

    init(
        id: UUID,
        username: String,
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.username = username
        self.name = name
        self.dosage = dosage
        self.frequencyRaw = frequency.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var frequency: MedicationFrequency {
        get { MedicationFrequency(rawValue: frequencyRaw)! }
        set { frequencyRaw = newValue.rawValue }
    }
}
