//
//  BBoxBuider.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox

struct BBoxBuider {
    let mapView: MGLMapView
    
    var string: String {
        // This method is called whenever the map's viewport changes.
        let visibleRegion = mapView.visibleCoordinateBounds
//              let centerCoordinate = mapView.centerCoordinate
        
        // Extract the coordinates of the southwest and northeast corners
        let southwestCoordinate = visibleRegion.sw
        let northeastCoordinate = visibleRegion.ne

        // Convert the coordinates to comma-separated strings
        let southwestString = "\(southwestCoordinate.longitude),\(southwestCoordinate.latitude)"
        let northeastString = "\(northeastCoordinate.longitude),\(northeastCoordinate.latitude)"
        
        return "\(southwestString),\(northeastString)"
    }
}
