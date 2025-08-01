//
//  MapboxAPICreator.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Combine

struct MapboxAPICreator {
    let url: URL?
    
    func build<Result:Decodable>() async throws -> Result {
        guard let url = url
        else { throw URLError(.badURL, userInfo: ["url": url?.absoluteString ?? "n/a"]) }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse
        else { throw URLError(.cannotParseResponse) }
        
        guard (200...209).contains(httpResponse.statusCode)
        else { throw URLError(.badServerResponse, userInfo: ["code": httpResponse.statusCode]) }
        
        return try JSONDecoder().decode(Result.self, from: data)
    }
}
