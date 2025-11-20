//
//  MZMapKitConfiguration.swift
//  MZMapKit
//
//  Created by MK-Mini on 20/11/2568 BE.
//

import Foundation

public struct MZMapKitConfiguration {
    public let baseURL: String
    public let timeout: TimeInterval
    public let session: URLSession
    
    public init(baseURL: String,
                timeout: TimeInterval,
                session: URLSession = .shared) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.session = session
    }
}
