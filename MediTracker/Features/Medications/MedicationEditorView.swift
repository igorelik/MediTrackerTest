import SwiftUI

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


    let viewModel: MedicationViewModel
    let existing: MedicationEntity?
    private let username = "test-user"

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
                        Text("No automatic reminders for as-needed medications.")
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
                reminderWeekdayTime: remindersEnabled ? reminderWeekdayTime : nil
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
                reminderWeekdayTime: remindersEnabled ? reminderWeekdayTime : nil
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
