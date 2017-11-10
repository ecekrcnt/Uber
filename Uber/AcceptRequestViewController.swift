//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Ece KARAÇANTA on 09/11/2017.
//  Copyright © 2017 Ece KARAÇANTA. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {
    
    @IBOutlet weak var map_accept: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var requestEmail = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map_accept.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map_accept.addAnnotation(annotation)
    }
   
    @IBAction func btn_accept(_ sender: Any) {
        // Update the ride Request
        Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat": self.driverLocation.latitude, "driverLon": self.driverLocation.longitude])
            Database.database().reference().child("RideRequest").removeAllObservers()
        }
        
        // Give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placeMark = MKPlacemark(placemark: placemarks[0]) //belirtilen koordinatla ilişkili ülke, eyalet, şehir ve sokak adresi gibi bilgileri içerir.
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
        
    }
    
    
    
}
