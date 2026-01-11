import Foundation
public protocol MedicationRepositoryProtocol: AnyObject {
    func medications() -> [MedicationEntity]
    func refresh() async throws
    func create(
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        remindersEnabled: Bool,
        reminderTime1: Date?,
        reminderTime2: Date?,
        reminderWeekday: Int?,
        reminderWeekdayTime: Date?,
        reminderAsNeededDate: Date?
    ) async throws

    func update(
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
    ) async throws
    func delete(entity: MedicationEntity) async throws
}

