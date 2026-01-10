import SwiftUI

struct MedicationEditorView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
 
    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: MedicationFrequency = .daily
    @State private var isSaving = false
    @State private var errorMessage: String?


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
                frequency: frequency
            )
        } else {
            await viewModel.create(
                name: name,
                dosage: dosage,
                frequency: frequency,
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
