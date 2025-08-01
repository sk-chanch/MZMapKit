//
//  MapboxRoutePointUpdater.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox
import Combine
import SwifterSwift
import SwiftUI

@MainActor
class MapboxRoutePointUpdater<RoutePin: View, RoutePinResponseModel: Codable>: ObservableObject {
    let isShowPoint: Bool
    
    weak var mapView: MGLMapView?
    var cancellable: Set<AnyCancellable> = .init()
    
    weak var configuration: MapViewConfigurationViewModel?
    weak var mapboxProxy: MapboxProxy?
    
    var allRoutePoint: [UserInfoMGLPointAnnotationView] {
        mapView?.annotations?
            .map{$0 as? UserInfoMGLPointAnnotationView}
            .filter{ $0?.isRoutePin ?? false }
            .compactMap{$0} ?? []
    }
    
    var task: Task<(), any Error>?
    var urlForRoutePin: ((_ bbox: String) -> (String))?
    var viewForRoutePin: (Any?) -> RoutePin
    var annotationForRoutePin: ((RoutePinResponseModel?) -> ([MGLPointAnnotation]))?
    var routePinSize: CGSize?
    
    init(mapView: MGLMapView?,
         mapboxProxy: MapboxProxy?,
         configuration: MapViewConfigurationViewModel?,
         isShowPoint: Bool,
         urlForRoutePin: ((_ bbox: String) -> (String))?,
         annotationForRoutePin: ((RoutePinResponseModel?) -> ([MGLPointAnnotation]))?,
         @ViewBuilder viewForRoutePin: @escaping (Any?) -> RoutePin,
         routePinSize: CGSize?
    ) {
        self.mapboxProxy = mapboxProxy
        self.mapView = mapView
        self.configuration = configuration
        self.isShowPoint = isShowPoint
        self.urlForRoutePin = urlForRoutePin
        self.viewForRoutePin = viewForRoutePin
        self.annotationForRoutePin = annotationForRoutePin
        self.routePinSize = routePinSize
        
        binding()
    }
    
    private func binding() {
        guard urlForRoutePin != nil
        else { return }
        
//        $routePointDataSource
//            .filter{ [weak self] _ in self?.isShowPoint ?? true }
//            .filter{[weak self] _ in self?.configuration?.isViewDisappear.negated ?? true }
//            .removeDuplicates()
//            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: true)
//            .map{[weak self] x -> [MGLPointAnnotation] in
//               
//                return x.filter{ $0.title != "Mission" }.map{self?.createAnnotation(with: $0, userInfo: 1)}.compactMap{$0}
//                
//            }
////                .filter{[weak self] _ in self?.isRegionChange.negated ?? false }
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: {[weak self] value in
//                guard value.count > 0
//                else {
//                    self?.mapView?.removeAnnotations(self?.allRoutePoint ?? [])
//                    return
//                }
//                
//                self?.mapView?.removeAnnotations(self?.allRoutePoint ?? [])
//                self?.mapView?.addAnnotations(value)
//                
////                    print("update RoutePoint")
//            })
//            .store(in: &cancellable)
        
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
        guard let mapView = self.mapView
        else { return }
        
        task?.cancel()
        
        task = Task { [weak self] in
            do {
                let pinResponseModel = try await self?.getRoutePoint(bbox: mapView.bboxString)
                
                let pinList = self?.annotationForRoutePin?(pinResponseModel) ?? []
                
                guard pinList.count > 0
                else { return }
                
                DispatchQueue.main.async {
                    
                    self?.mapView?.removeAnnotations(self?.allRoutePoint ?? [])
                    self?.mapView?.addAnnotations(pinList)
                }
                
            } catch let urlError as URLError {
                print("urlError \(urlError) | \(urlError.userInfo)")
            }
        }
    }
    
    func createAnnotation(with item:any AnnotationDataSourceModel, userInfo:Int) -> UserInfoMGLPointAnnotationView{
        let pa = UserInfoMGLPointAnnotationView()
        pa.title = item.title
        pa.subtitle = "\(item.id)"
        pa.coordinate = item.coord
        pa.userInfo = userInfo
        
        return pa
    }
    
    private func getRoutePoint(bbox: String) async throws -> RoutePinResponseModel {
        guard let url = urlForRoutePin?(bbox)
        else { fatalError("please setup urlForRoutePin") }
        
        return try await MapboxAPICreator(url: url.url).build()
    }
    
    //MARK: lookup the image to load by switching on the annotation's title string
    func viewForAnnotationRoutePoint(annotation: MGLAnnotation) -> CustomAnnotationViewRoutePoint<RoutePin>? {
        let reuseIdentifier = annotation.reuseIdentifier
        let view = CustomAnnotationViewRoutePoint(annotation: annotation,
                                                  reuseIdentifier: reuseIdentifier,
                                                  viewForRoutePin: viewForRoutePin)
        view.frame =  CGRect(origin: .zero, size: routePinSize ?? .init(width: 30, height: 30))
        
        return view
    }
}

