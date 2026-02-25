//
//  CustomAnnotationClusterView.swift
//  MapClusterDemo
//
//  Created by Chanchana Koedtho on 7/4/2567 BE.
//

import Foundation
import Mapbox
import UIKit
import SwiftUI
import ClusterKit

class CustomAnnotationClusterView<PinCluster: View>: MGLAnnotationView {
  
    private var hostingController: UIHostingController<PinCluster>?
    private var didUpdatecountTitle: ((String) -> Void)?
    
    let pinCluster: (CKCluster) -> PinCluster
    
    override var annotation: MGLAnnotation? {
        didSet {
            updateDataFromAnnotation()
        }
    }
    
    init(annotation: MGLAnnotation?,
         reuseIdentifier: String?,
         cluster: CKCluster,
         @ViewBuilder pinCluster: @escaping (CKCluster) -> PinCluster) {
      
        self.pinCluster = pinCluster
        
        self.hostingController = UIHostingController(rootView: pinCluster(cluster))
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        setupSwiftUIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSwiftUIView() {
        guard let hostingController
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
        
        let newPinCluster = pinCluster(cluster)
        
        self.hostingController?.rootView = newPinCluster
        self.layoutIfNeeded()
    }
}
