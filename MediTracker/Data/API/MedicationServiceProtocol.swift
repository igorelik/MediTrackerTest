import Foundation

public protocol MedicationServiceProtocol: AnyObject {
    func fetchMedications(username: String) async throws -> [MedicationDTO]
    func create(username: String, name: String, dosage: String, frequency: MedicationFrequency) async throws -> MedicationDTO
    func update(username: String, id: UUID, name: String?, dosage: String?, frequency: MedicationFrequency?) async throws -> MedicationDTO
    func delete(username: String, id: UUID) async throws
}
