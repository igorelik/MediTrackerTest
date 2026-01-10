import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \MedicationEntity.createdAt, order: .reverse)
    private var medications: [MedicationEntity]
    
    

    @State private var showingEditor = false
    @State private var pendingDeleteIndices: IndexSet? = nil
    @State private var selectedMedicationID: UUID? = nil
    @State private var selectedMedication: MedicationEntity? = nil

    private let repository: MedicationRepositoryProtocol
    
    public init(repository: MedicationRepositoryProtocol){
        self.repository = repository
    }

    private var viewModel: MedicationViewModel {
        return MedicationViewModel(repository: repository)
    }

    var body: some View {
        NavigationStack {
            List (selection: $selectedMedicationID){
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
                    pendingDeleteIndices = indexSet
                }
            }
            .onChange(of: selectedMedicationID) {
                if let selectedMedicationID {
                    selectedMedication = medications.first(where: { $0.id == selectedMedicationID })
                    print("medication found: \(selectedMedication?.name ?? "none")")
                }
                else {
                    selectedMedication = nil
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
            .sheet(item: $selectedMedication) {selected in
                NavigationStack {
                    MedicationEditorView(existing: selected)
                }
                .onDisappear() {
                    selectedMedicationID = nil
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.refresh()
            }
            .alert("Are you sure?", isPresented: Binding(get: { pendingDeleteIndices != nil }, set: { if !$0 { pendingDeleteIndices = nil } })) {
                Button("Delete", role: .destructive) {
                    if let indices = pendingDeleteIndices {
                        for index in indices {
                            let medication = medications[index]
                            Task {
                                await viewModel.delete(medication)
                            }
                        }
                        pendingDeleteIndices = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    pendingDeleteIndices = nil
                }
            } message: {
                Text("This will permanently delete the selected medication.")
            }
        }
    }
}
