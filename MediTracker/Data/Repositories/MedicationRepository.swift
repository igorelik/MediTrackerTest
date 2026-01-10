import Foundation
import SwiftData

public final class MedicationRepository: MedicationRepositoryProtocol {

    private let service: MedicationServiceProtocol
    private let context: ModelContext
    private let username = "test-user"

    public init(service: MedicationServiceProtocol, context: ModelContext) {
        self.service = service
        self.context = context
    }

    public func medications() -> [MedicationEntity] {
        let descriptor = FetchDescriptor<MedicationEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func refresh() async throws {
        let remote = try await service.fetchMedications(username: username)

        // Simple sync strategy 
        for item in remote {
            upsert(item.toEntity())
        }

        try context.save()
    }

    public func create(
        name: String,
        dosage: String,
        frequency: MedicationFrequency,
        username: String
    ) async throws {

        let dto = try await service.create(
            username: username,
            name: name,
            dosage: dosage,
            frequency: frequency
        )

        context.insert(dto.toEntity())
        try context.save()
    }

    @MainActor
    public func update(
        entity: MedicationEntity,
        name: String,
        dosage: String,
        frequency: MedicationFrequency
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
    }

    @MainActor
    public func delete(entity: MedicationEntity) async throws {
        try await service.delete(
            username: entity.username,
            id: entity.id
        )

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
