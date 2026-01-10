import Foundation

public final class MedicationService: MedicationServiceProtocol{

    private let baseURL = URL(string: "https://api-jictu6k26a-uc.a.run.app")!
    private let apiKey = "healthengine-mobile-test-2026"

    // MARK: - Public API
    public init() { }

    public func fetchMedications(username: String) async throws -> [MedicationDTO] {
        let request = makeRequest(
            path: "/users/\(username)/medications",
            method: "GET"
        )

        let response: ListResponse<[MedicationDTO]> =
            try await perform(request)

        return response.data
    }

    public func create(
        username: String,
        name: String,
        dosage: String,
        frequency: MedicationFrequency
    ) async throws -> MedicationDTO {

        let body = [
            "name": name,
            "dosage": dosage,
            "frequency": frequency.rawValue
        ]

        let request = makeRequest(
            path: "/users/\(username)/medications",
            method: "POST",
            body: body
        )

        let response: ListResponse<MedicationDTO> =
            try await perform(request)

        return response.data
    }

    public func update(
        username: String,
        id: UUID,
        name: String?,
        dosage: String?,
        frequency: MedicationFrequency?
    ) async throws -> MedicationDTO {

        var body: [String: String] = [:]
        if let name { body["name"] = name }
        if let dosage { body["dosage"] = dosage }
        if let frequency { body["frequency"] = frequency.rawValue }

        let request = makeRequest(
            path: "/users/\(username)/medications/\(id.uuidString.lowercased())",
            method: "PUT",
            body: body
        )

        let response: ListResponse<MedicationDTO> =
            try await perform(request)

        return response.data
    }

    public func delete(
        username: String,
        id: UUID
    ) async throws {
        let request = makeRequest(
            path: "/users/\(username)/medications/\(id.uuidString.lowercased())",
            method: "DELETE"
        )

        _ = try await perform(request) as EmptyResponse
    }
    
    // MARK: - private helpers
    private struct EmptyResponse: Codable {}
    
    private func makeRequest(
        path: String,
        method: String,
        body: [String: String]? = nil
    ) -> URLRequest {

        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)

        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        return request
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            print("Server returned status code: \(String(describing: (response as! HTTPURLResponse?)?.statusCode))")
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder.api.decode(T.self, from: data)
    }
}

