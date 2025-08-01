//
//  View+.swift
//  MZMapKit
//
//  Created by MK-Mini on 1/8/2568 BE.
//

import SwiftUI

extension View {
    func toUIHostingController(title:String? = nil) ->  UIHostingController<Self> {
        let host = UIHostingController(rootView: self)
        host.title = title
        return host
    }
}
