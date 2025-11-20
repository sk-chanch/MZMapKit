//
//  Encodable+.swift
//  MZMapKit
//
//  Created by MK-Mini on 20/11/2568 BE.
//

import Foundation

extension Encodable {
    func asDictionary() -> [String: String]? {
        do {
            // 1. Encode the object to JSON Data
            let data = try JSONEncoder().encode(self)
            
            // 2. Serialize the Data to a Dictionary
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            
            // 3. Cast the Dictionary to the desired type
            var dictionaryWithValueString: [String: String] = [:]
            
            dictionary?.forEach { key, value in
                dictionaryWithValueString[key] = "\(value)"
            }
            
            return dictionaryWithValueString
        } catch {
            print("Error converting to dictionary: \(error)")
            return nil
        }
    }
}
