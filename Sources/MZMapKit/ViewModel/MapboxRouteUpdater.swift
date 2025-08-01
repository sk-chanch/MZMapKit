//
//  MapboxRouteUpdater.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox
import Combine
import SwiftUI

@MainActor
class MapboxRouteUpdater<RouteLineResponseModel: Decodable>: ObservableObject {
    let isShowRoute: Bool
    
    weak var mapView: MGLMapView?
    var cancellable: Set<AnyCancellable> = .init()
    
    weak var configuration: MapViewConfigurationViewModel?
    weak var mapboxProxy: MapboxProxy?
    var task: Task<(), any Error>?
    var urlForRouteLine: ((_ bbox: String) -> (String))?
    let coordinatesForRouteLine: ((RouteLineResponseModel?) -> ([CLLocationCoordinate2D]?))?
    let routeLineColor: Color?
    
    init(mapView: MGLMapView?,
         mapboxProxy: MapboxProxy?,
         configuration: MapViewConfigurationViewModel?,
         isShowRoute: Bool,
         urlForRouteLine: ((_ bbox: String) -> (String))?,
         coordinatesForRouteLine: ((RouteLineResponseModel?) -> ([CLLocationCoordinate2D]?))?,
         routeLineColor: Color?
    ) {
        self.mapboxProxy = mapboxProxy
        self.mapView = mapView
        self.configuration = configuration
        self.isShowRoute = isShowRoute
        self.urlForRouteLine = urlForRouteLine
        self.coordinatesForRouteLine = coordinatesForRouteLine
        self.routeLineColor = routeLineColor
        
        binding()
    }
    
    private func binding() {
        guard urlForRouteLine != nil
        else { return }
        
        mapboxProxy?.regionDidChangeAnimated
            .delay(for: .seconds(2), scheduler: DispatchQueue.main )
            .sink(receiveValue: { [weak self] _ in
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
        guard isShowRoute
        else { return }
        
        guard let mapView = self.mapView
        else { return }
        
        task?.cancel()
        
        task = Task { [weak self] in
            do {
                let response = try await self?.getRoute(bbox: mapView.bboxString)
                
                guard let listCoord: [CLLocationCoordinate2D] = self?.coordinatesForRouteLine?(response)
                else { return }
                
                guard listCoord.count > 0
                else {
                    self?.clearPolyline()
                    return
                }
              
                self?.addRoute(listCoord)
                
            } catch let urlError as URLError {
                self?.clearPolyline()
                print("urlError \(urlError) | \(urlError.userInfo)")
            }
        }
    }
    
    private func getRoute(bbox: String) async throws -> RouteLineResponseModel {
        guard let url = urlForRouteLine?(bbox)
        else { fatalError("please setup urlForRouteLine") }
        
       return try await MapboxAPICreator(url: url.url).build()
    }
    
    func addRoute(_ routeCoordinates: [CLLocationCoordinate2D]){
        guard let mapView = self.mapView
        else { return }
        
        guard routeCoordinates.count > 0
        else { return }
                
        let polylineFeature = MGLPolylineFeature(coordinates: routeCoordinates, count: UInt(routeCoordinates.count))
        // Customize the polyline's properties
        polylineFeature.attributes["strokeColor"] = routeLineColor ?? .blue
        polylineFeature.attributes["lineWidth"] = 5.0
        
        var polylineSource: MGLShapeSource?
        
        // Remove the existing polyline source if it exists
        if let existingSource = mapView.style?.source(withIdentifier: "polyline") as? MGLShapeSource {
            existingSource.shape = polylineFeature
            polylineSource = existingSource
        } else {
            // Add the polyline feature to your map
            polylineSource = MGLShapeSource(identifier: "polyline", features: [polylineFeature], options: nil)
            mapView.style?.addSource(polylineSource!)
        }
        
        guard let polylineSource = polylineSource
        else { return }
        
      
        
        // Remove the existing polyline layer if it exists
        if mapView.style?.layer(withIdentifier: "polyline-layer") as? MGLLineStyleLayer == nil{
            let polylineLayer = MGLLineStyleLayer(identifier: "polyline-layer", source: polylineSource)
            polylineLayer.lineJoin = NSExpression(forConstantValue: "round")
            polylineLayer.lineCap = NSExpression(forConstantValue: "round")
            polylineLayer.lineOpacity = NSExpression(forConstantValue: 0.5)

            // Apply styling properties
            polylineLayer.lineWidth = NSExpression(forKeyPath: "lineWidth")
            polylineLayer.lineColor = NSExpression(forKeyPath: "strokeColor")
    //            polylineLayer.lineDashPattern = NSExpression(forConstantValue: [2, 2])
            mapView.style?.addLayer(polylineLayer)
        }
    }

    private func clearPolyline() {
        guard let mapView = self.mapView
        else { return }
        
        // Remove the existing polyline source if it exists
        if let existingSource = mapView.style?.source(withIdentifier: "polyline") as? MGLShapeSource {
            mapView.style?.removeSource(existingSource)
        }
        
        if let layer = mapView.style?.layer(withIdentifier: "polyline-layer") {
            mapView.style?.removeLayer(layer)
        }
    }
}
