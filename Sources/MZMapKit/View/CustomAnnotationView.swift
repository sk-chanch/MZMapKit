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
import ClusterKit

class CustomAnnotationView<PinContent: View>: MGLAnnotationView {
    
    private var pinBunder: ((Any?) -> PinContent)?
    
    private var hostingController: UIHostingController<PinContent>?
    private var didPinImageUpdate:  ( (URL?) -> Void)?
    private var didCateImageUpdate: ((URL?) -> Void)?
    private var didShowSubMissionUpdate: ((Bool) -> Void)?
    
    override var annotation: MGLAnnotation? {
        didSet {
            updateDataFromAnnotation()
        }
    }
    
    init(annotation: MGLAnnotation?,
         reuseIdentifier: String?,
         userInfo: Any?,
         @ViewBuilder pin: @escaping (Any?) -> PinContent ) {
        self.pinBunder = pin
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
        
        hostingController.view.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    private func updateDataFromAnnotation() {
        guard let cluster = annotation as? CKCluster
        else { return }
        
        var newUserInfo: Any? = nil
        
        
        if cluster.count == 1, let annotationInfo = cluster.firstAnnotation as? CustomPointAnnotation {
            newUserInfo = annotationInfo.userInfo
        }
        
        if let newView = pinBunder?(newUserInfo) {
            hostingController?.rootView = newView
            self.layoutIfNeeded()
        }
    }
    
}
