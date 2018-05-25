//
//  StateViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/22/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class StateViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var stateSelector: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let stateArray = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhoda Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]
    
    var stateSelected : String = ""
    var userSelectedFlag = false
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateArray[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateSelector.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        let defaultStateIndex = stateArray.index(of: "California")!
        stateSelector.selectRow(defaultStateIndex, inComponent: 0, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        userSelectedFlag = true
        stateSelected = self.stateArray[row] as String
        print(stateSelected)
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is CityViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        
        // Grab default value if delegate method wasn't triggered
        if (userSelectedFlag == false) {
            self.stateSelected = stateArray[(stateSelector.selectedRow(inComponent: 0))]
            print (self.stateSelected)
        }
        
        // Set global
        RentalCarApp.state = self.stateSelected

        let fullAddressString = address + " " + city + " " + state
        print (fullAddressString)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(fullAddressString) { (placemarks, error) in
            if (error != nil || placemarks?.first == nil) {
                    let alert = UIAlertController(title: "Please re-enter your address.", message: "We couldn't find that location.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                else
                {
                    let placemark = placemarks?.first
                    let lat = placemark?.location?.coordinate.latitude
                    let lon = placemark?.location?.coordinate.longitude
                    print(lat)
                    print(lon)
                    
                    RentalCarApp.location = CLLocationCoordinate2D(latitude: lat!, longitude: lon!)
                    newLocationSetFlag = true
                    
                    self.activityIndicator.stopAnimating()
                    
                    if let navController = self.navigationController {
                        for controller in navController.viewControllers {
                            if controller is HomeViewController {
                                navController.popToViewController(controller, animated:false)
                                break
                            }
                        }
                    }
                }
            }
        }
    
}
