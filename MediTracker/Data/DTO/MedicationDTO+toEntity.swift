import Foundation

extension MedicationDTO {
    func toEntity() -> MedicationEntity {
        MedicationEntity(
            id: id,
            username: username,
            name: name,
            dosage: dosage,
            frequency: MedicationFrequency(rawValue: frequency)!,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
