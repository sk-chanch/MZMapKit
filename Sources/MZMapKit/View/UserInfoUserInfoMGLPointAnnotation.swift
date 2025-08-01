//
//  UserInfoMGLAnnotationView.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 4/10/2566 BE.
//

import Foundation
import Mapbox


public class UserInfoMGLPointAnnotationView:MGLPointAnnotation{
    public var userInfo:Any?
    public var isRoutePin: Bool?
}
