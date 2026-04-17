//
//  MapboxAPICreator.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Combine

// MARK: - TrustKit Dummy Delegate
final class EmptySessionDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {}

struct MapboxAPICreator {
    let url: URL?
    
    let session: URLSession
    
    init(url: URL?) {
        self.url = url
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config, delegate: EmptySessionDelegate(), delegateQueue: nil)
    }
    
    func build<Result:Decodable>() async throws -> Result {
        guard let instant = MZMapKit.shared
        else { throw URLError(.badURL) }
        
        return try await instant.build(url: url)
    }
}
