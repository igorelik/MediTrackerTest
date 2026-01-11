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
    
    func create(name: String, dosage: String, frequency: MedicationFrequency, remindersEnabled: Bool = false, reminderTime1: Date? = nil, reminderTime2: Date? = nil, reminderWeekday: Int? = nil, reminderWeekdayTime: Date? = nil, reminderAsNeededDate: Date? = nil) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await repository.create(name: name, dosage: dosage, frequency: frequency, remindersEnabled: remindersEnabled, reminderTime1: reminderTime1, reminderTime2: reminderTime2, reminderWeekday: reminderWeekday, reminderWeekdayTime: reminderWeekdayTime, reminderAsNeededDate: reminderAsNeededDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func update( existing: MedicationEntity, name: String, dosage: String, frequency: MedicationFrequency, remindersEnabled: Bool = false, reminderTime1: Date? = nil, reminderTime2: Date? = nil, reminderWeekday: Int? = nil, reminderWeekdayTime: Date? = nil, reminderAsNeededDate: Date? = nil) async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            try await repository.update(entity: existing, name: name, dosage: dosage, frequency: frequency, remindersEnabled: remindersEnabled, reminderTime1: reminderTime1, reminderTime2: reminderTime2, reminderWeekday: reminderWeekday, reminderWeekdayTime: reminderWeekdayTime, reminderAsNeededDate: reminderAsNeededDate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
