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
}
