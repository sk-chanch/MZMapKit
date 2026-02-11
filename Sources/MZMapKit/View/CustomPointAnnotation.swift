//
//  CustomPointAnnotation.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 4/10/2566 BE.
//

import Foundation
import Mapbox


public class CustomPointAnnotation: MGLPointAnnotation {
    public var userInfo: Any? // for keep return type from api
    public var type: AnnotationViewType = .unknown // for catagory pin type
}
