import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \MedicationEntity.createdAt, order: .reverse)
    private var medications: [MedicationEntity]

    @State private var showingEditor = false
    @Environment(\.resolver) private var resolver

    private var viewModel: MedicationViewModel {
        let repo = resolver.makeRepository(context)
        return MedicationViewModel(repository: repo)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(medications) { medication in
                    VStack(alignment: .leading) {
                        Text(medication.name)
                            .font(.headline)

                        Text("\(medication.dosage) • \(medication.frequency.displayName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    // delete via repository
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add")
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    MedicationEditorView(existing: nil)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.refresh()
            }
        }
    }
}
