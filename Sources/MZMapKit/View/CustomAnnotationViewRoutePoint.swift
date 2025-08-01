//
//  CustomAnnotationViewRoutePoint.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 4/10/2566 BE.
//

import Foundation
import Mapbox
import SwiftUI

class CustomAnnotationViewRoutePoint<RoutePin: View>: MGLAnnotationView{
    private var hostingController: UIHostingController<RoutePin>
    
    
    init(annotation: MGLAnnotation?,
                  reuseIdentifier: String?,
                  @ViewBuilder viewForRoutePin: (Any?) -> RoutePin) {
        let info = (annotation as? UserInfoMGLPointAnnotationView)?.userInfo
        self.hostingController = .init(rootView: viewForRoutePin(info))
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        
        
        self.addSubview(hostingController.view)
        
        // First, disable translatesAutoresizingMaskIntoConstraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        if let superView = superview {
            // Then add constraints
            NSLayoutConstraint.activate([
                hostingController.view.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
                hostingController.view.topAnchor.constraint(equalTo: superView.topAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
            ])
        }
        
        hostingController.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            hostingController.view.frame = bounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hostingController.view.frame = bounds
    }
}


