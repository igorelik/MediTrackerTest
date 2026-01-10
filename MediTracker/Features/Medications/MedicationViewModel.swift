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
}
