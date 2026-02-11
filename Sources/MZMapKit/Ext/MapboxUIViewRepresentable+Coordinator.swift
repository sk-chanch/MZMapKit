//
//  MapboxUIViewRepresentable+Coordinator.swift
//  JERTAM
//
//  Created by Chanchana on 16/7/2567 BE.
//

import Foundation
import Mapbox
import MapboxDirections
import Combine
import ClusterKit


extension MapboxUIViewRepresentable {
    @MainActor
    public class Coordinator {
        var mapView: MGLMapView? {
            didSet {
                mapboxPinUpdater?.mapView = mapView
                mapboxRouteUpdater?.mapView = mapView
                mapboxRoutePointUpdater?.mapView = mapView
                mapboxDirectionBuider?.mapView = mapView
               
                bindingButtonOpenExpandMap()
            }
        }
        var parent:MapboxUIViewRepresentable
        
        lazy var tapPin: CustomPointAnnotation = {
            let pin = CustomPointAnnotation()
            pin.type = .droppedPin
            return pin
        }()
        
        var cancellable = Set<AnyCancellable>()
        
        let mapboxProxy: MapboxProxy? = .init()
        var mapboxPinUpdater: MapboxPinUpdater<PinContent, PinCluster, PinResponseModel>?
        var mapboxRouteUpdater: MapboxRouteUpdater<RouteLineResponseModel>?
        var mapboxRoutePointUpdater: MapboxRoutePointUpdater<RoutePin, RoutePinResponseModel>?
        var mapboxDirectionBuider: MapboxDirectionBuider?
        
        var isRegionChange = false
        private var hasBaindingExpandMapButton = false
        private weak var configuration: MapViewConfigurationViewModel?
        
        // MARK: - Init
        
        public init(parent: MapboxUIViewRepresentable,
             configuration: MapViewConfigurationViewModel?) {
            self.parent = parent
            self.configuration = configuration
            mapboxPinUpdater = .init(mapView: mapView,
                                     mapboxProxy: mapboxProxy,
                                     configuration: configuration,
                                     isShowPin: parent.isShowPin,
                                     pinView: parent.pinContent,
                                     urlForPin: parent.urlForPin,
                                     pinSize: parent.pinSize,
                                     clusterSize: parent.clusterSize,
                                     pinCluster: parent.pinCluster,
                                     onPinUpdate: {
                parent.onPinUpdate?()
            },
                                     annotationFor: parent.annotationFor)
            
            mapboxRouteUpdater = .init(mapView: mapView,
                                       mapboxProxy: mapboxProxy,
                                       configuration: configuration,
                                       isShowRoute: parent.isShowRoute,
                                       urlForRouteLine: parent.urlForRouteLine,
                                       coordinatesForRouteLine: parent.coordinatesForRouteLine,
                                       routeLineColor: parent.routeLineColor)
            
            mapboxRoutePointUpdater = .init(mapView: mapView,
                                            mapboxProxy: mapboxProxy,
                                            configuration: configuration,
                                            isShowPoint: parent.isShowPoint,
                                            urlForRoutePin: parent.urlForRoutePin,
                                            annotationForRoutePin: parent.annotationForRoutePin,
                                            viewForRoutePin: parent.viewForRoutePin,
                                            routePinSize: parent.routePinSize)
            
            mapboxDirectionBuider = .init(mapView: mapView)
            
            
            binding()
        }
        
        // MARK: - Private Method
        
        private func bindingButtonOpenExpandMap() {
            guard !hasBaindingExpandMapButton
            else { return }
            
            hasBaindingExpandMapButton = true
            
            setUpButtonExpand()
            
            mapView?.attributionButton.removeTarget(nil,
                                                    action: nil,
                                                    for: .allEvents)
            mapView?.attributionButton.addTarget(self, action: #selector(Coordinator.onTapAttributionButton), for: .touchUpInside)
        }
        
        @objc func onTapAttributionButton() {
            parent.didTapExpand?()
        }
        
        private func setUpButtonExpand() {
            mapView?.logoView.isHidden = true
            
            if let image = parent.attributionButtonImage {
                mapView?.attributionButton.setImage(image,
                                                    for: .normal)
            }
          
            mapView?.attributionButton.contentEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
            mapView?.attributionButton.tintColor = .white
            mapView?.attributionButton.backgroundColor = .init(parent.expandMapBackgroundButtonColor ?? .accentColor)
            mapView?.attributionButton.layer.cornerRadius = (mapView?.attributionButton.height ?? 1) / 2
            mapView?.attributionButton.isHidden = true
        }
        
        private func binding() {
            configuration?.forceClearTapGroundPin = {[weak self] in
                let exitingPin = self?.mapView?.annotations?
                    .compactMap{ $0 as? CustomPointAnnotation }
                    .first(where: {$0.type == .droppedPin })
                
                guard let exitingPin
                else { return }
                
                self?.mapView?.removeAnnotation(exitingPin)
                
            }
            
            configuration?.forceRefreshHandler = {[weak self] in
                
                self?.mapView?.setZoomLevel((self?.mapView?.zoomLevel ?? 19) - 1, animated: true)
            }
            
            configuration?.didRequestDirection = {[weak self] waypoints in
                Task {
                    try? await self?.mapboxDirectionBuider?.createDirection(waypoint: waypoints)
                }
            }
            
            configuration?.mapView = { [weak self] in
                return self?.mapView
            }
            
            mapboxProxy?.didFinishLoading
                .receive(on: DispatchQueue.main )
                .sink(receiveValue: { [weak self] _ in
                    self?.setUpDefaultZoom()
                    self?.handleDidFinishLoadingMap()
                })
                .store(in: &cancellable)
            
            mapboxProxy?.regionWillChangeWith
                .receive(on: DispatchQueue.main )
                .sink(receiveValue: { [weak self] _ in
                    
                    self?.isRegionChange = true
                })
                .store(in: &cancellable)
            
            mapboxProxy?.regionDidChangeAnimated
                .receive(on: DispatchQueue.main )
                .sink(receiveValue: { [weak self] _ in
                    
                    self?.parent.regionDidChangeAnimated?(self?.mapView)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?.isRegionChange = false
                    }
                })
                .store(in: &cancellable)
            
            mapboxProxy?.viewFor = { [weak self] mapView, annotation in
                guard annotation is MGLPointAnnotation || annotation is CKCluster
                else {
                    return nil
                }
                
                let pinType = (annotation as? CustomPointAnnotation)?.type ?? .unknown
                
                var annotationView: MGLAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pinType.identifier)
                
                // if the annotation image hasn‘t been used yet, initialize it here with the reuse identifier
                if annotationView == nil {
                    // lookup the image for this annotation
                    
                    // Check is Cluster Type
                    if let annotation = annotation as? CKCluster{
                        annotationView = self?.mapboxPinUpdater?.viewForAnnotation(annotation: annotation)
                    } else if let customAnnotation = annotation as? CustomPointAnnotation {
                     
                        switch customAnnotation.type {
                        case .custom :
                            if let pinCustomContent = self?.parent.pinCustomContent {
                                
                                guard let customPinSize = self?.parent.customPinSize
                                else { fatalError("please setup customPinSize") }
                                
                                annotationView = CustomAnnotationView(annotation: annotation,
                                                                      reuseIdentifier: pinType.identifier,
                                                                      userInfo: customAnnotation.userInfo,
                                                                      pin: pinCustomContent)
                                
                                annotationView?.frame = CGRect(origin: .zero, size: customPinSize)
                            }
                        case .routePoint:
                            annotationView = self?.mapboxRoutePointUpdater?.viewForAnnotationRoutePoint(annotation: annotation)
                        default:
                            break
                        }
                        
                    }
                }
                
                // ignore CustomMGLPolyline return nil
                return annotationView
            }
            
            mapboxProxy?.didSelect
                .compactMap{ $0 as? CKCluster }
                .receive(on: DispatchQueue.main )
                .sink(receiveValue: { [weak self] ck in
                    let pinCount = ck.count
                    
                    if pinCount > 1 {
                        let annotations = (ck.annotations as [AnyObject] )
                            .compactMap{ $0 as?  CustomPointAnnotation}.compactMap{ $0 }
                        self?.parent.didSelectCluster?(annotations)
                    } else if pinCount == 1, let annotation = ck.firstAnnotation as? CustomPointAnnotation{
                        self?.parent.didSelectPin?(annotation)
                    }
                   
                })
                .store(in: &cancellable)
        }
        
        private func setUpDefaultZoom() {
            mapView?.minimumZoomLevel = 10
            mapView?.maximumZoomLevel = 21
        }
        
        @objc func handleMapTap(_ gesture: UITapGestureRecognizer) {
            // Convert tap location (CGPoint) to geographic coordinate (CLLocationCoordinate2D).
            let tapPoint: CGPoint = gesture.location(in: mapView)
            guard let tapCoordinate: CLLocationCoordinate2D = mapView?.convert(tapPoint,
                                                                               toCoordinateFrom: nil)
            else { return }

            guard parent.didTapGround != nil
            else { return }
           
            tapPin.coordinate = tapCoordinate
            tapPin.type = .droppedPin
            
            if let exitingPin = mapView?.annotations?.compactMap { $0 as? CustomPointAnnotation }.first(where: {$0.type == .droppedPin}) {
                mapView?.removeAnnotation(exitingPin)
                parent.didClearTapGround?()
            
            }else{
                mapView?.addAnnotation(tapPin)
                parent.didTapGround?(tapCoordinate)
              
                
                mapView?.setCenter(tapCoordinate,
                                   animated: true)
                
            }
        }
    }
}

extension MapboxUIViewRepresentable.Coordinator {

    
    
    
    func handleDidFinishLoadingMap() {
        
        guard let mapView = self.mapView
        else { return }
        
        //Megazy Location
        var coord: CLLocationCoordinate2D = .init(latitude: 13.750632, longitude: 100.576161)
        
        if let userLocation = mapView.userLocation {
            coord = userLocation.coordinate
        }
        
        //Set first location default to megazy
        mapView.setCenter(coord,
                          zoomLevel: ProcessInfo.processInfo.isPreview && parent.coordinateFocus == nil ? 19 : parent.firstZoom ?? 17,
                          animated: false)
        
        //Hide button tap
        if parent.didTapExpand != nil, parent.isShowButtonExpandMap {
            mapView.attributionButton.isHidden = false
        }
        
        
        //Focus to target coordiante
        if let focusCoordinate = parent.coordinateFocus {
            let camera = MGLMapCamera()
            camera.centerCoordinate = focusCoordinate
            camera.viewingDistance = 150
            
            mapView.setCamera(camera,
                              withDuration: 0.3,
                              animationTimingFunction: nil,
                              edgePadding: .zero,
                              completionHandler: {
                //Callback closure didFinishLoadMap after finish
                self.parent.didFinishLoadMap?(mapView)
            })
            
        } else {
            //Callback closure didFinishLoadMap
            self.parent.didFinishLoadMap?(mapView)
        }
        
       
    }
}

