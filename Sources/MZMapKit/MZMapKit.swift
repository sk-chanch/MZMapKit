// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwifterSwift
import CoreLocation

public final class MZMapKit {
    // MARK: - Singleton
    public static var shared: MZMapKit?
    
    // MARK: - Properties
    private let configuration: MZMapKitConfiguration
    private let networkService: NetworkService
    
    
    // MARK: - Initializers
    public init(configuration: MZMapKitConfiguration) {
        self.configuration = configuration
        self.networkService = .init(configuration: configuration)
    }
    
    // MARK: - Setup
    public static func setup(configuration: MZMapKitConfiguration) {
        shared = MZMapKit(configuration: configuration)
    }
    
    // MARK: - Convenience Static Methods
    public static func fetchLocations<T: Decodable, Q: Encodable>(query: Q,
                                                                  mapToCoord: ((T) -> ([CLLocationCoordinate2D]?))) async throws -> [CLLocationCoordinate2D]? {
        guard let shared = shared
        else { throw URLError(.badURL) }
        
        let queryItems = query.asDictionary()?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        let response: T = try await shared.networkService.get(endpoint: "", queryItems: queryItems)
        
        return mapToCoord(response)
    }
    
    public func build<Result:Decodable>(url: URL?) async throws -> Result {
        guard let url = url
        else { throw URLError(.badURL, userInfo: ["url": url?.absoluteString ?? "n/a"]) }
        
        guard let shared = MZMapKit.shared
        else { throw URLError(.badURL) }
        
//        guard shared.configuration.session.delegate is EmptySessionDelegate
//        else { throw URLError(.badURL, userInfo: ["message": "Session delegate must be of type EmptySessionDelegate"]) }
        
        let (data, response) = try await shared.configuration.session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse
        else { throw URLError(.cannotParseResponse) }
        
        guard (200...209).contains(httpResponse.statusCode)
        else { throw URLError(.badServerResponse, userInfo: ["code": httpResponse.statusCode]) }
        
        return try JSONDecoder().decode(Result.self, from: data)
    }
    
}
