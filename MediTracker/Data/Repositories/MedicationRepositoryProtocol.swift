public protocol MedicationRepositoryProtocol: AnyObject {
    func medications() -> [MedicationEntity]
    func refresh() async throws
    func create(name: String, dosage: String, frequency: MedicationFrequency, username: String) async throws
    func update(entity: MedicationEntity, name: String, dosage: String, frequency: MedicationFrequency) async throws
    func delete(entity: MedicationEntity) async throws
}

