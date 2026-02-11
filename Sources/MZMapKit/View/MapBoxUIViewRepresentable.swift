//
//  MapboxUIViewRepresentable.swift
//  AppStarterKit
//
//  Created by Chanchana Koedtho on 26/9/2566 BE.
//

import Foundation
import Mapbox
import SwiftUI
import MapKit
import Combine
import SwifterSwift
import ClusterKit.Mapbox


class CustomMGLMapView: MGLMapView {
    deinit {
        print("map deinit")
    }
}

struct PinDefault: View {
    
    var body: some View {
        Circle()
            .fill(.red)
    }
}

public enum MapboxResponseEmptyModel: Codable {
    case none
}

public struct MapboxUIViewRepresentable<PinContent: View,
                                        PinCluster: View,
                                        PinCustom: View,
                                        PinResponseModel: Codable,
                                        RoutePin: View,
                                        RoutePinResponseModel: Codable,
                                        RouteLineResponseModel: Decodable>: UIViewRepresentable{
    // Pin View Builder
    var pinContent: (Any?) -> PinContent
    var pinCluster: (CKCluster) -> PinCluster
    var viewForRoutePin: (Any?) -> RoutePin
    var pinCustomContent: (Any?) -> PinCustom
    
    @Weak var configuration: MapViewConfigurationViewModel?
    
    // Setup
    var coordinateFocus:CLLocationCoordinate2D?
    var firstZoom: CGFloat?
    var attributionButtonImage: UIImage?
    var isShowRoute: Bool = true
    var isShowPin: Bool = true
    var isShowPoint: Bool = true
    var isShowButtonExpandMap: Bool = true
    
    // Main background map
    var layerURL: String?
    
    // Style
    var pinSize: CGSize?
    var clusterSize: CGSize?
    var routePinSize: CGSize?
    var routeLineColor: Color?
    var expandMapBackgroundButtonColor: Color?
    var customPinSize: CGSize?
    
    // Action
    var didSelectPin: ( (CustomPointAnnotation) -> Void )?
    var didTapGround: ( (CLLocationCoordinate2D) -> Void )?
    var didClearTapGround: ( () -> Void )?
    var didFinishLoadMap: ((MGLMapView)->())?
    var didTapExpand: (() -> Void)?
    var onPinUpdate: (()->())?
    var urlForPin: ((_ bbox: String) -> (String))?
    var didSelectCluster: (([CustomPointAnnotation])->())?
    
    // Build Pin Data
    var annotationFor: ((PinResponseModel?) -> ([MGLPointAnnotation]))?
    var annotationForRoutePin: ((RoutePinResponseModel?) -> ([MGLPointAnnotation]))?
    
    //for setup URL
    var urlForRoutePin: ((_ bbox: String) -> (String))?
    var urlForRouteLine: ((_ bbox: String) -> (String))?
    
    var regionDidChangeAnimated: ((MGLMapView?)->())?
    
    var coordinatesForRouteLine: ((RouteLineResponseModel?) -> ([CLLocationCoordinate2D]?))?
    
    public init(
        pinResponseModel: PinResponseModel.Type = MapboxResponseEmptyModel.self,
        routePinResponseModel: RoutePinResponseModel.Type = MapboxResponseEmptyModel.self,
        routeLineResponseModel: RouteLineResponseModel.Type = MapboxResponseEmptyModel.self,
        @ViewBuilder pinContent: @escaping (Any?) -> PinContent = { _ in Color.red },
        @ViewBuilder pinCluster: @escaping (CKCluster) -> PinCluster = { _ in Color.green },
        @ViewBuilder viewForRoutePin: @escaping (Any?) -> RoutePin = { _ in Color.blue },
        @ViewBuilder pinCustomContent: @escaping (Any?) -> PinCustom = { _ in Color.yellow }
    ) {
        self.pinContent = pinContent
        self.pinCluster = pinCluster
        self.viewForRoutePin = viewForRoutePin
        self.pinCustomContent = pinCustomContent
    }
    
    
    public func makeUIView(context: Context) -> MGLMapView {
        guard let layerURL = layerURL
        else { fatalError("Please setup layerURL") }
        
        let mapView = CustomMGLMapView(frame: .zero,
                                       styleURL: layerURL.url)
     
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 500
        
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
       
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator,
                                                          action: #selector(Coordinator.handleMapTap(_:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            tapGestureRecognizer.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        context.coordinator.mapView = mapView
        
        mapView.delegate = context.coordinator.mapboxProxy
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MGLMapView, context: Context) {
        
    }
  
    public func makeCoordinator() -> MapboxUIViewRepresentable.Coordinator {
        return Coordinator(parent: self, configuration: configuration)
    }
}


public class CustomMGLPolyline: MGLPolyline {
    var color: UIColor?
}
