import Foundation
import SwiftData

final class MedicationRepositoryPreview: MedicationRepositoryProtocol {

    private let context: ModelContext
    private let username: String

    init(context: ModelContext, username: String = "preview-user") {
        self.context = context
        self.username = username
        seedIfNeeded()
    }

    private func seedIfNeeded() {
        let descriptor = FetchDescriptor<MedicationEntity>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty { return }

        let now = Date()
        let samples = [
            MedicationEntity(id: UUID(), username: username, name: "Aspirin", dosage: "100 mg", frequency: .daily, createdAt: now, updatedAt: now),
            MedicationEntity(id: UUID(), username: username, name: "Vitamin D", dosage: "2000 IU", frequency: .daily, createdAt: now, updatedAt: now),
            MedicationEntity(id: UUID(), username: username, name: "Ibuprofen", dosage: "200 mg", frequency: .asNeeded, createdAt: now, updatedAt: now)
        ]

        for med in samples { context.insert(med) }
        try? context.save()
    }

    func medications() -> [MedicationEntity] {
        let descriptor = FetchDescriptor<MedicationEntity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    func refresh() async throws {
        // Preview repository has no remote, so no-op
    }

    func create(name: String, dosage: String, frequency: MedicationFrequency) async throws {
        let now = Date()
        let entity = MedicationEntity(id: UUID(), username: username, name: name, dosage: dosage, frequency: frequency, createdAt: now, updatedAt: now)
        context.insert(entity)
        try context.save()
    }

    @MainActor
    func update(entity: MedicationEntity, name: String, dosage: String, frequency: MedicationFrequency) async throws {
        entity.name = name
        entity.dosage = dosage
        entity.frequency = frequency
        entity.updatedAt = Date()
        try context.save()
    }

    @MainActor
    func delete(entity: MedicationEntity) async throws {
        context.delete(entity)
        try context.save()
    }
}
