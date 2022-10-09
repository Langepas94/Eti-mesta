//
//  MapVCViewController.swift
//  My Places (with comments)
//
//  Created by Артём Тюрморезов on 06.10.2022.
//

import UIKit
import MapKit
import CoreLocation
class MapVCViewController: UIViewController {
    
    let annotationViewIdentifier = "annotationViewIdentifier"
    var place = Place()
    let locationManager = CLLocationManager()
    let regioeters = 5000.0
    var segueId = ""
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImg: UIImageView!
    
    
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
    
    private func setupMapView() {
        if segueId == "showMap" {
            setupPlaceMark()
            mapPinImg.isHidden = true
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
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
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
}


extension MapVCViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuth()
    }
}
