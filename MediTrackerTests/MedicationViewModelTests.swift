import Foundation
import Testing
import SwiftData
@testable import MediTracker

final class MockRepository: MedicationRepositoryProtocol {
    var meds: [MedicationEntity] = []
    var didCallRefresh = false
    var didCallCreate: (name: String, dosage: String, frequency: MedicationFrequency)?
    var didCallUpdate: (entity: MedicationEntity, name: String, dosage: String, frequency: MedicationFrequency)?
    var didCallDelete: MedicationEntity?
    var shouldThrowOnRefresh = false

    func medications() -> [MedicationEntity] { meds }

    func refresh() async throws {
        didCallRefresh = true
        if shouldThrowOnRefresh { throw NSError(domain: "mock", code: 1) }
    }
  
    func create(name: String, dosage: String, frequency: MediTracker.MedicationFrequency, remindersEnabled: Bool, reminderTime1: Date?, reminderTime2: Date?, reminderWeekday: Int?, reminderWeekdayTime: Date?, reminderAsNeededDate: Date?) async throws {
        didCallCreate = (name, dosage, frequency)
        let e = MedicationEntity(id: UUID(), username: "u", name: name, dosage: dosage, frequency: frequency, createdAt: Date(), updatedAt: Date())
        meds.append(e)
    }

    @MainActor
    func update(entity: MediTracker.MedicationEntity, name: String, dosage: String, frequency: MediTracker.MedicationFrequency, remindersEnabled: Bool, reminderTime1: Date?, reminderTime2: Date?, reminderWeekday: Int?, reminderWeekdayTime: Date?, reminderAsNeededDate: Date?) async throws {
        didCallUpdate = (entity, name, dosage, frequency)
        if let idx = meds.firstIndex(where: { $0.id == entity.id }) {
            meds[idx].name = name
            meds[idx].dosage = dosage
            meds[idx].frequency = frequency
        }
    }

    @MainActor
    func delete(entity: MedicationEntity) async throws {
        didCallDelete = entity
        meds.removeAll(where: { $0.id == entity.id })
    }
}

struct MedicationViewModelTests {

    @Test func medicationsReflectRepository() {
        let repo = MockRepository()
        let e = MedicationEntity(id: UUID(), username: "u", name: "X", dosage: "1", frequency: .daily, createdAt: Date(), updatedAt: Date())
        repo.meds = [e]
        let vm = MedicationViewModel(repository: repo)

        #expect(vm.medications.count == 1)
        #expect(vm.medications.first?.name == "X")
    }

    @Test func createCallsRepository() async throws {
        let repo = MockRepository()
        let vm = await MedicationViewModel(repository: repo)

        await vm.create(name: "A", dosage: "D", frequency: .daily)

        #expect(repo.didCallCreate?.name == "A")
        #expect(vm.isRefreshing == false)
    }

    @Test func refreshHandlesError() async throws {
        let repo = MockRepository()
        repo.shouldThrowOnRefresh = true
        let vm = await MedicationViewModel(repository: repo)

        await vm.refresh()

        #expect(repo.didCallRefresh == true)
        #expect(vm.isRefreshing == false)
        #expect(vm.errorMessage != nil)
    }

    @Test func deleteCallsRepository() async throws {
        let repo = MockRepository()
        let e = MedicationEntity(id: UUID(), username: "u", name: "ToDelete", dosage: "1", frequency: .daily, createdAt: Date(), updatedAt: Date())
        repo.meds = [e]
        let vm = await MedicationViewModel(repository: repo)

        await vm.delete(e)

        #expect(repo.didCallDelete?.id == e.id)
        #expect(vm.isRefreshing == false)
    }
}
