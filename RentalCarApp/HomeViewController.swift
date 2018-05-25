//
//  HomeViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/21/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

let apiKey = "IN0qI3YNFCPpCSQvqntxvGDn4RGp3Min"
let apiRental = "https://api.sandbox.amadeus.com/v1.2/cars/search-circle?apikey=\(apiKey)&"

// User's specified address
var address : String = ""
var city : String = ""
var state : String = ""
var location = CLLocationCoordinate2D()
var newLocationSetFlag = false
var pickupDateAsString : String = ""
var dropoffDateAsString : String = ""
var radius : String = ""

// User data
var firstname : String = ""
var lastname : String = ""
var profilePicURL : String = ""

class HomeViewController : UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapAddressLabel: UILabel!
    @IBOutlet weak var mapActivityIndicator: UIActivityIndicatorView!
    
    // Location 
    let locationManager = CLLocationManager()
    
    // Map
    var mapAnnotation = MKPointAnnotation()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mapActivityIndicator.startAnimating()
        self.setupLocationManager()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewComponents()
        self.setupLocationManager()
        self.mapActivityIndicator.hidesWhenStopped = true
    }

    func setViewComponents(){
        // Set photo image
        if let url = NSURL(string: profilePicURL) {
            if let data = NSData(contentsOf: url as URL) {
                self.profileImage.image = UIImage(data: data as Data)
                
                // Make round profile image
                self.profileImage.layer.borderWidth = 1.0
                self.profileImage.layer.masksToBounds = false
                self.profileImage.layer.borderColor = UIColor.white.cgColor
                self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
                self.profileImage.clipsToBounds = true
            }
        }
    }
    @IBAction func findCarButtonPushed(_ sender: Any) {
        let pickupVC = self.storyboard?.instantiateViewController(withIdentifier: "PickUpDateViewController") as! PickUpDateViewController
        self.navigationController?.pushViewController(pickupVC, animated: true)
//        self.getSearchResults()
    }
    
    @IBAction func changeLocationButtonPushed(_ sender: Any) {
        let addressVC = self.storyboard?.instantiateViewController(withIdentifier: "AddressViewController") as! AddressViewController
        self.navigationController?.pushViewController(addressVC, animated: true)
    }
    
    func setupLocationManager() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (newLocationSetFlag == false)
        {
            let locationArray = locations as Array
            let locationObject = locationArray.last as! CLLocation
            let coordinate = locationObject.coordinate
            print(coordinate.latitude, coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            self.mapView.showsUserLocation = true
            self.mapAddressLabel.text = "\(firstname) \(lastname)\nSearch Area: Your Current Location"

            // Annotate
            mapAnnotation.coordinate = center
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(mapAnnotation)
            
            // Set global location
            RentalCarApp.location = coordinate
            
            self.initialLocationSetFlag = true
            locationManager.stopUpdatingLocation()
        }
        else
        {
            // Clear old annotations
            mapAnnotation.title = ""
            self.mapView.removeAnnotation(mapAnnotation)
            
            // Set new location for map
            let newCoordinate = location
            let newCenter = CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            let newRegion = MKCoordinateRegion(center: newCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
            // Annotate new location
            mapAnnotation.coordinate = newCenter
            
            // Redraw map
            self.mapView.setRegion(newRegion, animated: true)
            self.mapView.addAnnotation(mapAnnotation)
            
            self.mapAddressLabel.text = "\(firstname) \(lastname)\nSearch Area: \(address) \(city), \(state)"
            
            locationManager.stopUpdatingLocation()
        }
        
        self.mapActivityIndicator.stopAnimating()
    }
    
    @IBAction func signOutButtonPushed(_ sender: Any) {
    }
    
    func setFirstname(fname : String)
    {
        firstname = fname
    }
    
    func setLastname(lname : String)
    {
        lastname = lname
    }
    
    func setPicURL(urlString : String)
    {
        profilePicURL = urlString
    }
}

