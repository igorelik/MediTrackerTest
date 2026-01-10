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
        let authService = makeAuthenticationService()
        return MedicationRepository(service: medicationService, authService: authService, context: context)
    }
    
    public func makeAuthenticationService() -> AuthenticationServiceProtocol {
        AuthenticationService()
    }
}
