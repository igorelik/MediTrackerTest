import SwiftUI
import SwiftData
import UserNotifications

@main
struct MediTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MedicationListRoot()
        }
        .modelContainer(for: [MedicationEntity.self, NotificationEntity.self])
    }
}

private struct MedicationListRoot: View {
    @Environment(\.modelContext) private var context
    @Environment(\.resolver) private var resolver
    @State private var requestedNotificationPermission = false

    var body: some View {
        let repo = resolver.makeRepository(context: context)
        let authService = resolver.makeAuthenticationService()
        let permissionService = resolver.makeNotificationPermissionService()

        MedicationListView(repository: repo, authService: authService)
            .onAppear {
                guard !requestedNotificationPermission else { return }
                requestedNotificationPermission = true
                permissionService.requestAuthorization { _ in
                    // No-op; ReminderService schedules and UNUserNotificationCenter
                    // will ignore if permission is denied. Consider surfacing UI.
                }
            }
    }
}
