//
//  MGLMapVIew+FitToBound.swift
//  MZMapKit
//
//  Created by MK-Mini on 20/11/2568 BE.
//

import Mapbox

public extension MGLMapView {
    func fetchAndfitToBound<B: Encodable, T: Decodable>(_ query: B,
                                                                 edgePadding: UIEdgeInsets? = nil,
                                                                 mapToCoord: ((T) -> ([CLLocationCoordinate2D]?)),
                                                                 completionHandler: (() -> ())? = nil) async throws {
        let coordList = try await MZMapKit.fetchLocations(query: query, mapToCoord: mapToCoord)
        
        guard let coordList = coordList
        else { return }
        
        fitToBound(coordninates: coordList,
                   edgePadding: edgePadding,
                   animated: true,
                   completionHandler: completionHandler)
    }
}
