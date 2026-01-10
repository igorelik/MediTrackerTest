import SwiftUI
import SwiftData

@main
struct MediTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MedicationListView()
        }
        .modelContainer(for: MedicationEntity.self)
    }
}
