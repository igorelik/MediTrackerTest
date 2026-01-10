public enum MedicationFrequency: String, CaseIterable {
    case daily
    case twiceDaily = "twice_daily"
    case weekly
    case asNeeded = "as_needed"

    var displayName: String {
        switch self {
        case .daily: "Daily"
        case .twiceDaily: "Twice Daily"
        case .weekly: "Weekly"
        case .asNeeded: "As Needed"
        }
    }
}
