//
//  MapViewConfigurationViewModel.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import CoreLocation
import Mapbox
import Combine
import MapboxDirections

@MainActor
public class MapViewConfigurationViewModel: ObservableObject {
  
    public var mapView: (()->(MGLMapView?))?
    
    public var forceClearTapGroundPin:(()->())?
    
    public var forceRefreshHandler:(()->())?
    
    public var didRequestDirection:(([Waypoint])->())?
    
    public var cancellable: Set<AnyCancellable> = .init()
    
    public init() {
        
    }
    
    public func clearTapGrouldPin(){
        forceClearTapGroundPin?()
    }
    
    public func forceRefresh(){
        forceRefreshHandler?()
    }
    
    public func requestDirection(waypoints:[Waypoint]){
        didRequestDirection?(waypoints)
    }
}
