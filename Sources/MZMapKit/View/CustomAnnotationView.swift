//
//  CustomAnnotationView.swift
//  FIrstFullSwiftUI
//
//  Created by Chanchana Koedtho on 27/9/2566 BE.
//

import Foundation
import Mapbox
import SwifterSwift
import SwiftUI

class CustomAnnotationView<PinContent: View>: MGLAnnotationView {
    private var hostingController: UIHostingController<PinContent>?
    private var didPinImageUpdate:  ( (URL?) -> Void)?
    private var didCateImageUpdate: ((URL?) -> Void)?
    private var didShowSubMissionUpdate: ((Bool) -> Void)?
    
    
    init(annotation: MGLAnnotation?,
         reuseIdentifier: String?,
         userInfo: Any?,
         @ViewBuilder pin: @escaping (Any?) -> PinContent ) {
        
        self.hostingController = .init(rootView: pin(userInfo))
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupSwiftUIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private func setupSwiftUIView() {
        guard let hostingController = hostingController
        else { return }
        
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
       
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        backgroundColor = .clear
    }
}
