//
//  MapVCViewController.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 06.10.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapVcDelegate {
    func getAddress(_ address: String?)
}

class MapVCViewController: UIViewController {
    var mapVcDelegate: MapVcDelegate?
    let annotationViewIdentifier = "annotationViewIdentifier"
    var place = Place()
    let locationManager = CLLocationManager()
    let regioeters = 5000.0
    var segueId = ""
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImg: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    var placeCoordinat: CLLocationCoordinate2D?
    var countOfDirections: [MKDirections] = []
    var previousLocation:  CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocServ()
    }
    
    @IBAction func centerOnUserLocation() {
        
        showUserLocation()
//        if let location = locationManager.location?.coordinate {
//            let region  = MKCoordinateRegion(center: location, latitudinalMeters: regioeters, longitudinalMeters: regioeters)
//            mapView.setRegion(region, animated: true)
//        }
        
    }
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    @IBAction func goButtonTapped() {
        getDirections()
    }
    
    
    @IBAction func doneButtontapped() {
        mapVcDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if segueId == "showMap" {
            setupPlaceMark()
            mapPinImg.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            addressLabel.text = ""
            goButton.isHidden = false
        }
    }
    
    private func setupPlaceMark() {
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
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placeMarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placeMarkLocation.coordinate
            self.placeCoordinat = placeMarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func resetMapView(new directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        countOfDirections.append(directions)
        let _ = countOfDirections.map {$0.cancel()}
        countOfDirections.removeAll()
    }
    
//    private func сheckLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            setupLocationManager()
//            checkLocationAuth()
//        } else {
//            // show alert
//        }
//    }
    
    private func checkLocServ() {
                if CLLocationManager.locationServicesEnabled() {
                    setupLocationManager()
                    checkLocationAuth()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showAlert(title: "Location are disabled", message: "Enable it in geo privacy")
                    }
                }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = .greatestFiniteMagnitude
      
    }
    
    private func checkLocationAuth() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueId == "getAddress"{
                showUserLocation()
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
    
    private func showAlert(title: String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func getCenterLocation(for mapview: MKMapView) -> CLLocation {
        let latitude = mapview.centerCoordinate.latitude
        let longitude = mapview.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func startTrackingUserLocation() {
        guard let previousLocation = previousLocation else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return}
        self.previousLocation = center
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUserLocation()
        }
    }
    
    
    private func getDirections() {
        guard let location = locationManager.location?.coordinate
        else {
            showAlert(title: "Error", message: "Location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(new: directions)
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
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let time = route.expectedTravelTime
                
                print("Расстояние до места \(distance) км")
                print("Время в пути составит \(distance) сек")
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
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
    
    
    private func showUserLocation() {
                if let location = locationManager.location?.coordinate {
                    let region  = MKCoordinateRegion(center: location, latitudinalMeters: regioeters, longitudinalMeters: regioeters)
                    mapView.setRegion(region, animated: true)
                }
    }
    
  

}

extension MapVCViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
            let imageForBanner = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageForBanner.layer.cornerRadius = 10
            imageForBanner.clipsToBounds = true
            imageForBanner.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageForBanner
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if segueId == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil, buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
            
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}


extension MapVCViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuth()
    }
}
