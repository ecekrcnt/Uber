//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Ece KARAÇANTA on 09/11/2017.
//  Copyright © 2017 Ece KARAÇANTA. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequest : [DataSnapshot] = [] //Veritabanı verilerini her okunduğunda, veriler bir DataSnapshot olarak alınır.
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequest").observe(.childAdded) { (snapshot) in
            if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                    
                } else {
                    self.rideRequest.append(snapshot)
                    self.tableView.reloadData()
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequest.count
    }
    
    @IBAction func btn_logOut(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequest[indexPath.row]
        
        if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
            if let email = rideRequestDictionary["email"] as? String {
                if let lat = rideRequestDictionary["lat"] as? Double {
                    if let lon = rideRequestDictionary["lon"] as? Double {
                        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon)
                        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
                        let roundedDistance = round(distance * 100) / 100
                        cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequest[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rideRequestDictionary["email"] as? String {
                        if let lat = rideRequestDictionary["lat"] as? Double {
                            if let lon = rideRequestDictionary["lon"] as? Double {
                                acceptVC.requestEmail = email
                                 let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                acceptVC.requestLocation = location
                                acceptVC.driverLocation = driverLocation
                            }
                        }
                    }
                }
            }
        }
    }
}
