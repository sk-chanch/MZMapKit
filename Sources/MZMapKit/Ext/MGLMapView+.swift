//
//  MGLMapView+.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox
import SwiftUI

public extension MGLMapView {
    var bboxString: String {
        // This method is called whenever the map's viewport changes.
        let visibleRegion = visibleCoordinateBounds
        //              let centerCoordinate = mapView.centerCoordinate
        
        // Extract the coordinates of the southwest and northeast corners
        let southwestCoordinate = visibleRegion.sw
        let northeastCoordinate = visibleRegion.ne
        
        // Convert the coordinates to comma-separated strings
        let southwestString = "\(southwestCoordinate.longitude),\(southwestCoordinate.latitude)"
        let northeastString = "\(northeastCoordinate.longitude),\(northeastCoordinate.latitude)"
        
        return "\(southwestString),\(northeastString)"
    }
    
    func clearMinZoom(zoom: Double = 0) {
        minimumZoomLevel = zoom
    }
    
    
    func fitToBound(coordninates: [CLLocationCoordinate2D], edgePadding: UIEdgeInsets? = nil, animated: Bool = true, completionHandler: (() -> ())? = nil) {
        clearMinZoom()
        //zoom level + 1 for load new pin
        setTrackingModeNone()
        self.setZoomLevel(self.zoomLevel + 1, animated: true)
        self.setVisibleCoordinates(coordninates,
                                   count: UInt(coordninates.count),
                                   edgePadding: edgePadding ?? .init(horizontal: 0, vertical: 100),
                                   direction: 0,
                                   duration: animated ? 0.3 : 0,
                                   animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut),
                                   completionHandler: completionHandler)
    }
    
    func moveCamera(coord: CLLocationCoordinate2D, edgePadding: UIEdgeInsets) {
        let camera = MGLMapCamera()
        camera.centerCoordinate = coord
        setCamera(camera,
                  withDuration: 0.3,
                  animationTimingFunction: nil,
                  edgePadding: edgePadding)
    }
    
    func setModeFollowWithHeading() {
        
        guard let center = self.userLocation?.coordinate
        else { return }
        
        let camera = MGLMapCamera()
        camera.centerCoordinate = center
        camera.viewingDistance = 0
        camera.pitch = 60
        camera.heading = self.userLocation?.heading?.trueHeading ?? 0
        
        self.setCamera(camera,
                       withDuration: 0.25,
                       animationTimingFunction: nil,
                       edgePadding: .zero)
    }
    
    func setTrackingModeNone() {
        
        guard let center = self.userLocation?.coordinate
        else { return }
        
        let camera = MGLMapCamera()
        camera.centerCoordinate = center
        camera.viewingDistance = 2000
        camera.pitch = 0
        camera.heading = 0
        
        self.setCamera(camera,
                       withDuration: 0,
                       animationTimingFunction: nil,
                       edgePadding: .zero)
    }
    
    func updateTracking(trackingMode: Binding<MGLUserTrackingMode>, hasMapScrolledAwayFromUser: Bool) {
        
        guard hasMapScrolledAwayFromUser
        else {
            if trackingMode.wrappedValue == .followWithHeading {
                // Adjust the camera's altitude and heading to change the pitch angle
                setModeFollowWithHeading()
                
            } else if trackingMode.wrappedValue == MGLUserTrackingMode.none {
                setTrackingModeNone()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.userTrackingMode = trackingMode.wrappedValue
                if trackingMode.wrappedValue == .none {
                    self.camera.heading = 0
                }
            }
            
            return
        }
      
        let changeModeTo: MGLUserTrackingMode = trackingMode.wrappedValue != .followWithHeading ? .followWithHeading : .none
        
        guard changeModeTo != trackingMode.wrappedValue
        else { return }
        
        trackingMode.wrappedValue = changeModeTo
        
        guard userTrackingMode != trackingMode.wrappedValue
        else { return }
        
        userTrackingMode = .follow
        
        if trackingMode.wrappedValue == .followWithHeading {
            // Adjust the camera's altitude and heading to change the pitch angle
            setModeFollowWithHeading()
            
        } else if trackingMode.wrappedValue == MGLUserTrackingMode.none {
            setTrackingModeNone()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.userTrackingMode = trackingMode.wrappedValue
            if trackingMode.wrappedValue == .none {
                self.camera.heading = 0
            }
        }
    }
    
    func isInCoordinateBounds(_ coord: CLLocationCoordinate2D?) -> Bool {
        guard let coord = coord
        else { return false }
        
        // Calculate visible bounds around the user's location
        let userCoordinate = coord
        // Define a desired distance (in meters) around the user's location to be visible on the map
        let desiredDistance: CLLocationDistance = 10 // Adjust as needed

        // Calculate the span in degrees based on the desired distance
        let metersPerDegree: CLLocationDistance = 111000 // Approximate value
        let latitudeSpan = desiredDistance / metersPerDegree
        let longitudeSpan = latitudeSpan / cos(userCoordinate.latitude * .pi / 180)

        // Calculate the bounds based on the user's location and the span
        let northeastCoordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude + latitudeSpan,
                                                         longitude: userCoordinate.longitude + longitudeSpan)
        
        let southwestCoordinate = CLLocationCoordinate2D(latitude: userCoordinate.latitude - latitudeSpan,
                                                         longitude: userCoordinate.longitude - longitudeSpan)

  
        // Create the MGLCoordinateBounds
        let bounds = MGLCoordinateBounds(sw: southwestCoordinate, ne: northeastCoordinate)

        return MGLCoordinateInCoordinateBounds(centerCoordinate, bounds)
    }
}
