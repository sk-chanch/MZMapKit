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

class CustomAnnotationClusterView<PinCluster: View>: MGLAnnotationView{
    private var hostingController: UIHostingController<PinCluster>?
    private var didUpdatecountTitle: ((String) -> Void)?
    
    let pinCluster: (CKCluster) -> PinCluster
    let cluster: CKCluster
    
    init(annotation: MGLAnnotation?,
         reuseIdentifier: String?,
         cluster: CKCluster,
         @ViewBuilder pinCluster: @escaping (CKCluster) -> PinCluster) {
        self.pinCluster = pinCluster
        self.cluster = cluster
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        setupSwiftUIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSwiftUIView() {
        let hostingController =  pinCluster(cluster).toUIHostingController()
        
        self.hostingController = hostingController
        
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
