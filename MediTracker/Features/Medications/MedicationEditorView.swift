import SwiftUI

struct MedicationEditorView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.resolver) private var resolver

    let existing: MedicationEntity?

    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var frequency: MedicationFrequency = .daily
    @State private var isSaving = false
    @State private var errorMessage: String?

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

        let repository = resolver.makeRepository(context: context)

        do {
            if let existing {
                try await repository.update(
                    entity: existing,
                    name: name,
                    dosage: dosage,
                    frequency: frequency
                )
            } else {
                try await repository.create(
                    name: name,
                    dosage: dosage,
                    frequency: frequency,
                    username: username
                )
            }

            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
