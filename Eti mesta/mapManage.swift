//
//  mapManage.swift
//  Eti mesta
//
//  Created by Артём Тюрморезов on 10.10.2022.
//

import Foundation
import UIKit
import MapKit

class MapManage {
    let locationManager = CLLocationManager()
    let regioeters = 5000.0
    var placeCoordinat: CLLocationCoordinate2D?
    var countOfDirections: [MKDirections] = []
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print("error")
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinat = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func checkLocServ(mapView: MKMapView, segueId: String, closure: () -> ()) {
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    checkLocationAuth(mapView: mapView, segueId: segueId)
                    closure()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showAlert(title: "Location are disabled", message: "Enable it in geo privacy")
                    }
                }
    }
    
    func checkLocationAuth(mapView: MKMapView , segueId: String) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueId == "getAddress"{
                showUserLocation(mapView: mapView)
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location are disabled", message: "Enable it in geo privacy")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("new case is available")
        }
    }
    
    func showUserLocation(mapView: MKMapView) {
                if let location = locationManager.location?.coordinate {
                    let region  = MKCoordinateRegion(center: location, latitudinalMeters: regioeters, longitudinalMeters: regioeters)
                    mapView.setRegion(region, animated: true)
                }
    }
    
    func getDirections(mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        guard let location = locationManager.location?.coordinate
        else {
            showAlert(title: "Error", message: "Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(new: directions, mapView: mapView)
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.showAlert(title: "Error", message: "DIrection is not avilable")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let time = route.expectedTravelTime
                
                print("Расстояние до места \(distance) км")
                print("Время в пути составит \(distance) сек")
            }
        }
    }
    
    func resetMapView(new directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        countOfDirections.append(directions)
        let _ = countOfDirections.map {$0.cancel()}
        countOfDirections.removeAll()
    }
    
    
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinat else { return nil }
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        return request
    }
    

    func startTrackingUserLocation(mapView: MKMapView, location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return}
        closure(center)
    }
    
    func getCenterLocation(for mapview: MKMapView) -> CLLocation {
        let latitude = mapview.centerCoordinate.latitude
        let longitude = mapview.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    
    
}
