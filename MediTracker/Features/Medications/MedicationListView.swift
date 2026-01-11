import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var context
 
    @Query(sort: \MedicationEntity.createdAt, order: .reverse)
    private var medications: [MedicationEntity]
    
    @State private var showingEditor = false
    @State private var showingLogin = false
    @State private var pendingDeleteIndices: IndexSet? = nil
    @State private var selectedMedicationID: UUID? = nil
    @State private var selectedMedication: MedicationEntity? = nil

    private let repository: MedicationRepositoryProtocol
    private let authService: AuthenticationServiceProtocol
    
    public init(repository: MedicationRepositoryProtocol, authService: AuthenticationServiceProtocol){
        self.repository = repository
        self.authService = authService
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
            .navigationTitle("Medications for \(authService.username)")
            .toolbar {
                Button {
                    showingEditor = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add")
                Button {
                    Task {
                        try await authService.logout()
                        showingLogin = true
                    }
                } label: {
                    Image(systemName: "figure.walk.departure")
                }
                .accessibilityLabel("Logout")
            }
            .sheet(isPresented: $showingLogin) {
                LoginView(authService: authService, isPresented: $showingLogin)
                    .interactiveDismissDisabled(true)
                    .onDisappear() {
                        if authService.isLoggedIn {
                            Task {
                                await viewModel.refresh()
                            }
                        } else {
                            showingLogin = true
                        }
                    }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    MedicationEditorView(viewModel: viewModel, existing: nil)
                }
                .onDisappear() {
                    Task {
                        await viewModel.refresh()
                    }
                }
            }
            .sheet(item: $selectedMedication) {selected in
                NavigationStack {
                    MedicationEditorView(viewModel: viewModel, existing: selected)
                }
                .onDisappear() {
                    Task {
                        selectedMedicationID = nil
                        await viewModel.refresh()
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if authService.isLoggedIn {
                    await viewModel.refresh()
                } else {
                    showingLogin = true
                }
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

struct MedicationListView_Previews: PreviewProvider {
    static var previewContext: ModelContext = {
        let ctx = ModelContext(try! ModelContainer(for: MedicationEntity.self, NotificationEntity.self))
        return ctx
    }()
    
    static var previews: some View {
        MedicationListView(repository: MedicationRepositoryPreview(context: previewContext), authService: AuthenticationServicePreview())
            .environment(\.modelContext, previewContext)
    }
}

