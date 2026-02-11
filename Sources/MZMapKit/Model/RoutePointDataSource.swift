//
//  RoutePointDataSource.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 4/10/2566 BE.
//

import Foundation
import CoreLocation


struct RoutePointDataSource: AnnotationDataSourceModel {
   
    let id: Int
    let title:String
    let coord: CLLocationCoordinate2D
    
}

extension RoutePointDataSource: Equatable {
    static func == (lhs: RoutePointDataSource, rhs: RoutePointDataSource) -> Bool {
        lhs.id == rhs.id
    }
    
}
