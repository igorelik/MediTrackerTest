import Foundation

@Observable
final class MedicationViewModel {

    private let repository: MedicationRepositoryProtocol

    var isRefreshing = false
    var errorMessage: String?

    init(repository: MedicationRepositoryProtocol) {
        self.repository = repository
    }

    var medications: [MedicationEntity] {
        repository.medications()
    }

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await repository.refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func delete(_ medication: MedicationEntity) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await repository.delete(entity: medication)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func create(name: String, dosage: String, frequency: MedicationFrequency) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await repository.create(name: name, dosage: dosage, frequency: frequency)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func update( existing: MedicationEntity, name: String, dosage: String, frequency: MedicationFrequency) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await repository.update(entity: existing, name: name, dosage: dosage, frequency: frequency)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
