//
//  RiderViewController.swift
//  Uber
//
//  Created by Ece KARAÇANTA on 08/11/2017.
//  Copyright © 2017 Ece KARAÇANTA. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map_rider: MKMapView!
    @IBOutlet weak var btnOutlet_callUber: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberHasBeenCalled = true
                self.btnOutlet_callUber.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequest").removeAllObservers()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
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
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_callAnUber(_ sender: Any) {
        
        if let email = Auth.auth().currentUser?.email {
            if uberHasBeenCalled {
                uberHasBeenCalled = false
                btnOutlet_callUber.setTitle("Call an Uber", for: .normal)
                Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequest").removeAllObservers()
                })
                
            } else {
                let rideRequestDictionary : [String:Any] = ["email" : email, "lat" : userLocation.latitude, "lon" : userLocation.longitude]
                Database.database().reference().child("RideRequest").childByAutoId().setValue(rideRequestDictionary )
                uberHasBeenCalled = true
                btnOutlet_callUber.setTitle("Cancel Uber", for: .normal)
                
            }
        }
    }
}
