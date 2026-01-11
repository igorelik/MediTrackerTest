import Foundation
import Testing
import SwiftData
@testable import MediTracker

final class MockAuthService: AuthenticationServiceProtocol {
    var username: String
    var isLoggedIn: Bool { !username.isEmpty }

    init(username: String) { self.username = username }

    func login(username: String, password: String) async throws { self.username = username }
    func logout() async throws { self.username = String() }
}

final class MockMedicationService: MedicationServiceProtocol {
    var responses: [MedicationDTO] = []

    func fetchMedications(username: String) async throws -> [MedicationDTO] {
        return responses
    }

    func create(username: String, name: String, dosage: String, frequency: MedicationFrequency) async throws -> MedicationDTO {
        let dto = MedicationDTO(id: UUID(), username: username, name: name, dosage: dosage, frequency: frequency.rawValue, createdAt: Date(), updatedAt: Date())
        responses.append(dto)
        return dto
    }

    func update(username: String, id: UUID, name: String?, dosage: String?, frequency: MedicationFrequency?) async throws -> MedicationDTO {
        if let idx = responses.firstIndex(where: { $0.id == id }) {
            var existing = responses[idx]
            existing = MedicationDTO(id: existing.id, username: existing.username, name: name ?? existing.name, dosage: dosage ?? existing.dosage, frequency: (frequency ?? MedicationFrequency(rawValue: existing.frequency)!).rawValue, createdAt: existing.createdAt, updatedAt: Date())
            responses[idx] = existing
            return existing
        }
        throw NSError(domain: "mock", code: 1)
    }

    func delete(username: String, id: UUID) async throws {
        responses.removeAll(where: { $0.id == id })
    }
}

struct MedicationRepositoryTests {

    func makeContext() throws -> ModelContext  {
        let modelConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContext(ModelContainer(for: MedicationEntity.self, configurations: modelConfig))
    }

    @Test func createAddsEntity() async throws {
        let ctx = try makeContext()
        let service = MockMedicationService()
        let auth = MockAuthService(username: "tester")
        let repo = await MedicationRepository(service: service, authService: auth, context: ctx)

        try await repo.create(name: "Aspirin", dosage: "100mg", frequency: .daily)

        let meds = await repo.medications()
        #expect(meds.count == 1)
        let m = meds.first!
        #expect(m.name == "Aspirin")
        #expect(m.dosage == "100mg")
        #expect(m.username == "tester")
    }
    
    @Test func updateChangesEntity() async throws {
        let ctx = try makeContext()
        let service = MockMedicationService()
        let auth = MockAuthService(username: "tester")
        let repo = await MedicationRepository(service: service, authService: auth, context: ctx)

        // initial remote set: two items
        try await repo.create(name: "One", dosage: "1mg", frequency: .daily)
        try await repo.create(name: "Two", dosage: "2mg", frequency: .daily)
       
        let meds = await repo.medications()
        #expect(meds.count == 2)
        let m = meds.first!
        try await repo.update(entity: m, name: "Aspirin", dosage: "100mg", frequency: .daily)
        let updatedMeds = await repo.medications()
        #expect(updatedMeds.count == 2)
        let updatedMed = updatedMeds.first!
        #expect(updatedMed.name == "Aspirin")
        #expect(updatedMed.dosage == "100mg")
    }
    
    @Test func deleteRemovesEntity() async throws {
        let ctx = try makeContext()
        let service = MockMedicationService()
        let auth = MockAuthService(username: "tester")
        let repo = await MedicationRepository(service: service, authService: auth, context: ctx)

        // initial remote set: two items
        try await repo.create(name: "One", dosage: "1mg", frequency: .daily)
        try await repo.create(name: "Two", dosage: "2mg", frequency: .daily)
       
        let meds = await repo.medications()
        #expect(meds.count == 2)
        let m = meds.first!
        try await repo.delete(entity: m)
        
        let updatedMeds = await repo.medications()
        #expect(updatedMeds.count == 1)
        let lastMed = updatedMeds.first!
        #expect(lastMed.name == "One")
        #expect(lastMed.dosage == "1mg")
    }

    @Test func refreshUpsertsAndRemoves() async throws {
        let ctx = try makeContext()
        let service = MockMedicationService()
        let auth = MockAuthService(username: "tester")
        let repo = await MedicationRepository(service: service, authService: auth, context: ctx)

        // initial remote set: two items
        let dto1 = MedicationDTO(id: UUID(), username: "tester", name: "One", dosage: "1", frequency: MedicationFrequency.daily.rawValue, createdAt: Date(), updatedAt: Date())
        let dto2 = MedicationDTO(id: UUID(), username: "tester", name: "Two", dosage: "2", frequency: MedicationFrequency.daily.rawValue, createdAt: Date(), updatedAt: Date())
        service.responses = [dto1, dto2]

        try await repo.refresh()
        #expect(try await repo.medications().count == 2)

        // remote now only contains dto1 (dto2 deleted)
        service.responses = [dto1]
        try await repo.refresh()
        #expect(try await repo.medications().count == 1)
        let remaining = await repo.medications().first!
        #expect(remaining.id == dto1.id)
    }

}
