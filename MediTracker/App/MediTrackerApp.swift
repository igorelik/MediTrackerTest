import SwiftUI
import SwiftData

@main
struct MediTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MedicationListRoot()
        }
        .modelContainer(for: MedicationEntity.self)
    }
}

private struct MedicationListRoot: View {
    @Environment(\.modelContext) private var context
    @Environment(\.resolver) private var resolver

    var body: some View {
        let repo = resolver.makeRepository(context: context)
        let authService = resolver.makeAuthenticationService()
        MedicationListView(repository: repo, authService: authService)
    }
}
