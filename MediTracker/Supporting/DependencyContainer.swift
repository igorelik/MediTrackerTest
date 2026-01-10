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
    public func makeRepository(context: ModelContext) -> MedicationRepositoryProtocol {
        let configService = ConfigurationService()
        let medicationService = MedicationService(configuration: configService)
        return MedicationRepository(service: medicationService, context: context)
        
    }
    
//    public var makeService: () -> MedicationServiceProtocol
//    public var makeRepository: (ModelContext) -> MedicationRepositoryProtocol
//    public var makeConfigurationService: () -> ConfigurationServiceProtocol
// 
//    public init(
//        makeService: @escaping () -> MedicationServiceProtocol = { MedicationService(configuration: ConfigurationService()) },
//        makeRepository: @escaping (ModelContext) -> MedicationRepositoryProtocol = { context in
//            MedicationRepository(service: MedicationService(configuration: ConfigurationService()), context: context)
//        },
//        makeConfigurationService: @escaping () -> ConfigurationServiceProtocol = { ConfigurationService() }
//    ) {
//        self.makeService = makeService
//        self.makeRepository = makeRepository
//        self.makeConfigurationService = makeConfigurationService
//    }
}
