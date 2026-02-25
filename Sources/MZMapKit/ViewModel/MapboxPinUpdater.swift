//
//  MapboxPinUpdater.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox
import Combine
import ClusterKit
import SwifterSwift
import SwiftUI

protocol Annotationable {
    
}

@MainActor
class MapboxPinUpdater<PinContent: View, PinCluster: View, MapResponseModel: Codable>: ObservableObject {
    let isShowPin: Bool
    
    weak var mapView: MGLMapView? {
        didSet {
            mapView?.clusterManager.maxZoomLevel = 25.5
        }
    }
    var cancellable: Set<AnyCancellable> = .init()
    var getPincancellable: Set<AnyCancellable> = .init()
    
    var allPin:[CustomPointAnnotation]{
        mapView?.annotations?
            .map{$0 as? CustomPointAnnotation}
            .filter{ $0?.type == .pinItem }
            .compactMap{$0} ?? []
    }
    weak var configuration: MapViewConfigurationViewModel?
    weak var mapboxProxy: MapboxProxy?
    var task: Task<(), any Error>?
    
    var onPinUpdate: (() -> Void)?
    
    var pinView: (Any?) -> PinContent
    let pinCluster: (CKCluster) -> PinCluster
    
    let urlForPin: ((_ : String) -> (String))?
    let pinSize: CGSize?
    let clusterSize: CGSize?
    let annotationFor: ((MapResponseModel?) -> ([MGLPointAnnotation]))?
    
    init(mapView: MGLMapView?,
         mapboxProxy: MapboxProxy?,
         configuration: MapViewConfigurationViewModel?,
         isShowPin: Bool,
         @ViewBuilder pinView: @escaping  (Any?) -> PinContent,
         urlForPin: ((_ : String) -> (String))?,
         pinSize: CGSize?,
         clusterSize: CGSize?,
         @ViewBuilder pinCluster: @escaping (CKCluster) -> PinCluster,
         onPinUpdate: (() -> Void)?,
         annotationFor: ((MapResponseModel?) -> ([MGLPointAnnotation]))?
    ) {
        self.mapboxProxy = mapboxProxy
        self.mapView = mapView
        self.configuration = configuration
        self.isShowPin = isShowPin
        self.onPinUpdate = onPinUpdate
        self.pinView = pinView
        self.urlForPin = urlForPin
        self.pinSize = pinSize
        self.pinCluster = pinCluster
        self.clusterSize = clusterSize
        self.annotationFor = annotationFor
        binding()
    }
    
    private func binding() {
        guard urlForPin != nil
        else { return }
                
        
        mapboxProxy?.regionDidChangeAnimated
            .sink(receiveValue: { [weak self] _ in
                self?.getPincancellable = .init()
                self?.update()
            })
            .store(in: &cancellable)
        
        mapboxProxy?.didFinishLoading
            .receive(on: DispatchQueue.main )
            .sink(receiveValue: { [weak self] _ in
                self?.update()
            })
            .store(in: &cancellable)
    }
    
    func update() {
        task?.cancel()
        
        task = Task { [weak self] in
            guard let mapView = self?.mapView
            else { return }
            
            do {
                let pinResponseModel = try await self?.getPin(bbox: mapView.bboxString)
                
                guard !Task.isCancelled else { return }
                
                let pinList = self?.annotationFor?(pinResponseModel) ?? []
                
                await MainActor.run { [weak self] in
                    
                    if pinList.isEmpty {
                        self?.mapView?.clusterManager.annotations = []
                    } else {
                        self?.mapView?.clusterManager.annotations = pinList
                    }
                    
                    
                    self?.mapView?.clusterManager.updateClustersIfNeeded()
                    
                    self?.onPinUpdate?()
                }
                
            } catch let error as URLError {
                print("urlError \(error) | \(error.userInfo)")
            }
        }
    }
    
    private func getPin(bbox: String) async throws -> MapResponseModel {
        guard let url = urlForPin?(bbox)
        else { fatalError("please setup urlForPin") }
        
        return try await MapboxAPICreator(url: url.url).build()
    }
    
    
    //MARK: lookup the image to load by switching on the annotation's title string
    func viewForAnnotation(annotation: MGLAnnotation) -> MGLAnnotationView? {
        let reuseIdentifier = (annotation as? CustomPointAnnotation)?.type ?? .unknown
        
        guard let cluster = annotation as? CKCluster
        else { return nil }
        
        if cluster.count > 1 {
            guard let clusterSize = clusterSize
            else { fatalError("please setup clusterSize") }
            
            var v = mapView?.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier.identifier) as? CustomAnnotationClusterView<PinCluster>
            
            if v == nil {
                v = CustomAnnotationClusterView(annotation: annotation,
                                                    reuseIdentifier: reuseIdentifier.identifier,
                                                    cluster: cluster,
                                                    pinCluster: pinCluster)
               
            } else {
                v?.annotation = annotation
            }
            
            v?.frame =  CGRect(origin: .zero, size: clusterSize)
            
            return v
        } else if let annotationInfo = cluster.firstAnnotation as? CustomPointAnnotation , cluster.count == 1 {
            
            guard let pinSize = pinSize
            else { fatalError("please setup pinSize") }
            
            var view = mapView?.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier.identifier) as? CustomAnnotationView<PinContent>
            
            if view == nil {
                view = CustomAnnotationView(annotation: annotation,
                                            reuseIdentifier: reuseIdentifier.identifier,
                                            userInfo: annotationInfo.userInfo,
                                            pin: pinView)
            }
            
            view?.frame = CGRect(origin: .zero, size: pinSize)
            
            return view
        } else {
            return nil
        }
    }
}
