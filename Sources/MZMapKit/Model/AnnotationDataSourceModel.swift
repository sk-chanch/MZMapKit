//
//  AnnotationDataSource.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 4/10/2566 BE.
//

import Foundation
import CoreLocation

protocol AnnotationDataSourceModel:Identifiable{
    var title:String { get}
    var id:Int { get}
    var coord:CLLocationCoordinate2D {get}
}
