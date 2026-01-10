import Foundation

public struct MedicationDTO: Codable {
    let id: UUID
    let username: String
    let name: String
    let dosage: String
    let frequency: String
    let createdAt: Date
    let updatedAt: Date
}

struct ListResponse<T: Codable>: Codable {
    let data: T
}
