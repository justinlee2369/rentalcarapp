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

// User data
var firstname : String = ""
var lastname : String = ""
var profilePicURL : String = ""

class HomeViewController : UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapAddressLabel: UILabel!
    
    // Parameters
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var initialLocationSetFlag = false
    var radiusInKilometers = 32 // 20ish miles
    var pickUpDate = "2018-07-07"
    var dropOffDate = "2018-07-08"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewComponents()
        self.setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func setViewComponents(){        
        // Set photo image
        if let url = NSURL(string: profilePicURL) {
            if let data = NSData(contentsOf: url as URL) {
                self.profileImage.image = UIImage(data: data as Data)
            }
        }
    }
    @IBAction func findCarButtonPushed(_ sender: Any) {
        self.getSearchResults()
    }
    
    @IBAction func changeLocationButtonPushed(_ sender: Any) {
        // Segue
//        self.changeLocation()
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
        
        var mapAnnotation = MKPointAnnotation()
        
        if (newLocationSetFlag == false)
        {
            let locationArray = locations as Array
            let locationObject = locationArray.last as! CLLocation
            let coordinate = locationObject.coordinate
            print(coordinate.latitude, coordinate.longitude)
            
            let center = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            self.mapView.showsUserLocation = true
            self.mapAddressLabel.text = "SEARCH AREA: YOUR CURRENT LOCATION"

            // Annotate
            mapAnnotation.coordinate = center
            mapAnnotation.title = firstname + " " + lastname
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(mapAnnotation)
            
            self.currentLocation = coordinate
            self.initialLocationSetFlag = true
        }
        else
        {
            // Clear old annotations
            self.mapView.removeAnnotation(mapAnnotation)
            
            // Set new location for map
            let newCoordinate = location
            let newCenter = CLLocationCoordinate2D(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            let newRegion = MKCoordinateRegion(center: newCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
            // Annotate new location
            mapAnnotation.coordinate = newCenter
            mapAnnotation.title = "\(firstname)'s New Search Location"
            
            // Redraw map
            self.mapView.setRegion(newRegion, animated: true)
            self.mapView.addAnnotation(mapAnnotation)
            
            self.mapAddressLabel.text = "SEACH AREA: \(address)"
        }
    }
    
    func getSearchResults() {
        //GET /v1.2/cars/search-circle?apikey=IN0qI3YNFCPpCSQvqntxvGDn4RGp3Min&latitude=35.1504&longitude=-114.57632&radius=42&pick_up=2018-06-07&drop_off=2018-06-08
        let latitude = self.currentLocation.latitude
        let longitude = self.currentLocation.longitude
            
        let parameters : String! = "latitude=\(latitude)&longitude=\(longitude)&radius=\(self.radiusInKilometers)&pick_up=\(self.pickUpDate)&drop_off=\(self.dropOffDate)"
            
        let urlString = apiRental + parameters
        
        print (urlString)
        
        let dataTask = URLSession.shared.dataTask(with: URL.init(string: urlString)!) { (data, response, error) in
            if ((data) != nil)
            {
                let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String:Any]
                
                if (json?["results"]) == nil  {
//                    fail((json?["message"] as? String) ?? "Unknown server error")
                    print(json?["message"])
                }
                else
                {
                    print(json?["results"])
                }
            }
            else
            {
            }
        }
        dataTask.resume()
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

