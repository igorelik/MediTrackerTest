import SwiftUI
import SwiftData

struct MedicationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
 
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: MedicationFrequency = .daily
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var remindersEnabled: Bool = false
    @State private var reminderTime1: Date = Date()
    @State private var reminderTime2: Date = Date()
    @State private var reminderWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @State private var reminderWeekdayTime: Date = Date()
    @State private var reminderAsNeededDate: Date = Date()

    let viewModel: MedicationViewModel
    let existing: MedicationEntity?
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("Name", text: $name)
                TextField("Dosage", text: $dosage)

                Picker("Frequency", selection: $frequency) {
                    ForEach(MedicationFrequency.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
            }

            Section("Reminders") {
                Toggle("Enable reminders", isOn: $remindersEnabled)

                if remindersEnabled {
                    switch frequency {
                    case .asNeeded:
                        VStack(alignment: .leading) {
                            DatePicker("Select date", selection: $reminderAsNeededDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                            DatePicker("Time", selection: $reminderAsNeededDate, displayedComponents: .hourAndMinute)
                        }
                    case .daily:
                        DatePicker("Time", selection: $reminderTime1, displayedComponents: .hourAndMinute)
                    case .twiceDaily:
                        DatePicker("Morning/First time", selection: $reminderTime1, displayedComponents: .hourAndMinute)
                        DatePicker("Evening/Second time", selection: $reminderTime2, displayedComponents: .hourAndMinute)
                    case .weekly:
                        Picker("Day", selection: $reminderWeekday) {
                            ForEach(1...7, id: \.self) { idx in
                                Text(Calendar.current.weekdaySymbols[idx - 1]).tag(idx)
                            }
                        }
                        DatePicker("Time", selection: $reminderWeekdayTime, displayedComponents: .hourAndMinute)
                    }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle(existing == nil ? "Add Medication" : "Edit Medication")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await save() }
                }
                .disabled(isSaving)
            }
        }
        .onAppear {
            if let existing {
                name = existing.name
                dosage = existing.dosage
                frequency = existing.frequency
                if let n1 = existing.notification1{
                    remindersEnabled = true
                    switch frequency {
                    case .daily:
                        reminderTime1 = n1.notificationTime ?? Date()
                    case .twiceDaily:
                        reminderTime1 = n1.notificationTime ?? Date()
                    case .weekly:
                        reminderWeekdayTime = n1.notificationTime ?? Date()
                        reminderWeekday = n1.weekday ?? Calendar.current.component(.weekday, from: Date())
                    case .asNeeded:
                        reminderAsNeededDate = n1.notificationTime ?? Date()
                    }
                }
                else {
                    remindersEnabled = false
                }
                if let n2 = existing.notification1 {
                    reminderTime2 = n2.notificationTime ?? Date()
                }
            }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        if let existing {
            await viewModel.update(
                existing: existing,
                name: name,
                dosage: dosage,
                frequency: frequency,
                remindersEnabled: remindersEnabled,
                reminderTime1: remindersEnabled ? reminderTime1 : nil,
                reminderTime2: remindersEnabled ? reminderTime2 : nil,
                reminderWeekday: remindersEnabled ? reminderWeekday : nil,
                reminderWeekdayTime: remindersEnabled ? reminderWeekdayTime : nil,
                reminderAsNeededDate: remindersEnabled ? reminderAsNeededDate : nil
            )
        } else {
            await viewModel.create(
                name: name,
                dosage: dosage,
                frequency: frequency,
                remindersEnabled: remindersEnabled,
                reminderTime1: remindersEnabled ? reminderTime1 : nil,
                reminderTime2: remindersEnabled ? reminderTime2 : nil,
                reminderWeekday: remindersEnabled ? reminderWeekday : nil,
                reminderWeekdayTime: remindersEnabled ? reminderWeekdayTime : nil,
                reminderAsNeededDate: remindersEnabled ? reminderAsNeededDate : nil
            )
        }
        if let vmError = viewModel.errorMessage,!vmError.isEmpty {
            errorMessage = vmError
        }
        else {
            dismiss()
        }
    }
}
