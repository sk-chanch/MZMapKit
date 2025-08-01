//
//  MGLAnnotation+.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox

extension MGLAnnotation {
    
    var reuseIdentifier: String {
//        var reuseIdentifier = "\(coordinate.latitude),\(coordinate.longitude)"
//        if let title = title, title != nil {
//            reuseIdentifier += title!
//        }
//        if let subtitle = subtitle, subtitle != nil {
//            reuseIdentifier += subtitle!
//        }
//        return reuseIdentifier
        return UUID().uuidString
    }
}
