//
//  AnnotationViewType.swift
//  MZMapKit
//
//  Created by MK-Mini on 11/2/2569 BE.
//

public enum AnnotationViewType: String {
    case cluster    // Group of place pin
    case pinItem    // Pin place (Standard)
    case routePoint // Point ex. water service
    case custom     // Custom with other view
    case droppedPin
    case unknown
    
    var identifier: String {
        return self.rawValue
    }
}
