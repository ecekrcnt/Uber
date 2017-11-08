//
//  RiderViewController.swift
//  Uber
//
//  Created by Ece KARAÇANTA on 08/11/2017.
//  Copyright © 2017 Ece KARAÇANTA. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map_rider: MKMapView!
    @IBOutlet weak var btnOutlet_callUber: UIButton!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map_rider.setRegion(region, animated: true)
            map_rider.removeAnnotations(map_rider.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            map_rider.addAnnotation(annotation)
        }
    }
    
    @IBAction func btn_logOut(_ sender: Any) {
    }
    
    @IBAction func btn_callAnUber(_ sender: Any) {
    }
    
}
