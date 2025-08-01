//
//  MapboxProxy.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Combine
import Mapbox
import ClusterKit

class MapboxProxy: NSObject, MGLMapViewDelegate {
    
    let regionWillChangeWith = PassthroughSubject<(MGLCameraChangeReason, Bool)?, Never>()
    let regionDidChangeAnimated = PassthroughSubject<Bool?, Never>()
    let didSelect = PassthroughSubject<MGLAnnotation?, Never>()
    let didFinishLoading = PassthroughSubject<MGLMapView?, Never>()
    
    var viewFor: ((MGLMapView, MGLAnnotation) -> (MGLAnnotationView?))?
    
    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
        guard fullyRendered
        else { return }
        
        didFinishLoading.send(mapView)
    }
    
    func mapView(_ mapView: MGLMapView, regionWillChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        regionWillChangeWith.send((reason, animated))
    }
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        regionDidChangeAnimated.send(animated)
    }

    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return viewFor?(mapView, annotation)
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        didSelect.send(annotation)
       
        if let ckCluster = annotation as? CKCluster {
            mapView.deselect(ckCluster, animated: false)
        } else {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 1
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        
        return 5
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        return (annotation as? CustomMGLPolyline)?.color ?? .blue
    }
}
