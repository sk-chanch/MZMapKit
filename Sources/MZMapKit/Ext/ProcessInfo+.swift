//
//  ProcessInfo+.swift
//  AppStarterKit
//
//  Created by Chanchana Koedtho on 11/10/2566 BE.
//

import Foundation


extension ProcessInfo{
    var isPreview:Bool{
        self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
