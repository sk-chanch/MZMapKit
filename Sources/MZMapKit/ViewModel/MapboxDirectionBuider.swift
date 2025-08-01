//
//  MapboxDirectionBuider.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Combine
import MapboxDirections
import Mapbox

class MapboxDirectionBuider {
    var cancellable = Set<AnyCancellable>()
    
    weak var mapView: MGLMapView?
    
    var allWaypoints:[CustomMGLPolyline]{
        mapView?.annotations?
            .map{$0 as? CustomMGLPolyline}
            .filter{$0?.title == "waypoint"}
            .compactMap{$0} ?? []
    }
    var wayPoinEnd: MGLPointAnnotation?
    
    init(mapView: MGLMapView?) {
        self.mapView = mapView
    }
    
    public func createDirection(waypoint:[Waypoint]) async throws {
        
        if allWaypoints.count > 0 {
            await mapView?.removeAnnotations(allWaypoints)
        }
        
        
        let routeList = try await createDirectionAsync(waypoint: waypoint) ?? []
        
        let routeLine = CustomMGLPolyline(coordinates: routeList,
                                          count: UInt(routeList.count))
        
        routeLine.title = "waypoint"
        routeLine.color = .blue
        
        // Add the polyline to the map.
        await mapView?.addAnnotation(routeLine)
        
        // Fit the viewport to the polyline.
        guard let camera = await mapView?.cameraThatFitsShape(routeLine,
                                                              direction: 0,
                                                              edgePadding: .init(top: 112,
                                                                                 left: 112,
                                                                                 bottom: 112,
                                                                                 right: 112))
        else {
            
            return
        }
        
        await mapView?.setCamera(camera, animated: true)
        
        if let lastCoord = waypoint.last?.coordinate  {
            wayPoinEnd = MGLPointAnnotation()
            wayPoinEnd?.coordinate = lastCoord
            wayPoinEnd?.title = "waypoint"
            await mapView?.addAnnotation((wayPoinEnd)!)
        }
    }
    
    private func createDirectionAsync(waypoint: [Waypoint]) async throws -> [CLLocationCoordinate2D]? {
        try await withCheckedThrowingContinuation { continuation in
            let routeOption = RouteOptions(waypoints: waypoint,
                                           profileIdentifier: .automobile)
            
            let task = Directions.shared.calculate(routeOption){ session, result in
                switch result {
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                    
                case .success(let response):
                    guard let route = response.routes?.first,
                          let _ = route.legs.first else {
                        
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    guard let routeCoordinates = route.shape?.coordinates,
                          routeCoordinates.count > 0
                    else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    continuation.resume(returning: routeCoordinates)
                }
            }
            
            task.resume()
        }
    }
    
    deinit {
        //hideAllSwiftMessagesUseCase.execute()
    }
}
