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
    let mapManage = MapManage()
    var mapVcDelegate: MapVcDelegate?
    let annotationViewIdentifier = "annotationViewIdentifier"
    var place = Place()
    
    
    var segueId = ""
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImg: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
   
    var previousLocation:  CLLocation? {
        didSet {
            mapManage.startTrackingUserLocation(mapView: mapView, location: previousLocation) { currentLocation in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManage.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
    @IBAction func centerOnUserLocation() {
        mapManage.showUserLocation(mapView: mapView)
        
//        if let location = locationManager.location?.coordinate {
//            let region  = MKCoordinateRegion(center: location, latitudinalMeters: regioeters, longitudinalMeters: regioeters)
//            mapView.setRegion(region, animated: true)
//        }
        
    }
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    @IBAction func goButtonTapped() {
        mapManage.getDirections(mapView: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    
    @IBAction func doneButtontapped() {
        mapVcDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    
    private func setupMapView() {
        
        goButton.isHidden = true
        
        if segueId == "showMap" {
            mapManage.setupPlaceMark(place: place, mapView: mapView)
            mapPinImg.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            addressLabel.text = ""
            goButton.isHidden = false
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

    private func setupLocationManager() {
        mapManage.locationManager.delegate = self
        mapManage.locationManager.desiredAccuracy = .greatestFiniteMagnitude
      
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
        let center = mapManage.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if segueId == "showMap" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManage.showUserLocation(mapView: self.mapView)
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
        mapManage.checkLocationAuth(mapView: mapView, segueId: segueId)
    }
}
