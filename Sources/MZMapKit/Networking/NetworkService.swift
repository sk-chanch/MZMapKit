//
//  NetworkService.swift
//  MZMapKit
//
//  Created by MK-Mini on 20/11/2568 BE.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(error: Error)
}

public final class NetworkService {
    private let session: URLSession
    private let baseURL: String
    private let timeout: TimeInterval
    
    public init(configuration: MZMapKitConfiguration) {
        self.baseURL = configuration.baseURL
        self.session = configuration.session
        self.timeout = configuration.timeout
    }
    
    public func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        // Build URL
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Decode
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error: error)
        }
    }
}
