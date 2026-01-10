import SwiftUI
import SwiftData

// MARK: - Resolver
public struct ResolverKey: EnvironmentKey {
    public static let defaultValue: Resolver = Resolver()
}

extension EnvironmentValues {
    public var resolver: Resolver {
        get { self[ResolverKey.self] }
        set { self[ResolverKey.self] = newValue }
    }
}

public final class Resolver {
    public var makeService: () -> MedicationServiceProtocol
    public var makeRepository: (ModelContext) -> MedicationRepositoryProtocol
 
    public init(
        makeService: @escaping () -> MedicationServiceProtocol = { MedicationService() },
        makeRepository: @escaping (ModelContext) -> MedicationRepositoryProtocol = { context in
            MedicationRepository(service: MedicationService(), context: context)
        }
    ) {
        self.makeService = makeService
        self.makeRepository = makeRepository
    }
}
