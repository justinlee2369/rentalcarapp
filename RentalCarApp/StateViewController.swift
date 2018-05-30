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
    
    let stateArray = ["ALABAMA", "ALASKA", "ARIZONA", "ARKANSAS", "CALIFORNIA", "COLORADO", "CONNECTICUT", "DELAWARE", "FLORIDA", "GEORGIA", "HAWAII", "IDAHO", "ILLINOIS", "INDIANA", "IOWA", "KANSAS", "KENTUCKY", "LOUISIANA", "MAINE", "MARYLAND", "MASSACHUSETTS", "MICHIGAN", "MINNESOTA", "MISSISSIPPI", "MISSOURI", "MONTANA", "NEBRASKA", "NEVADA", "NEW HAMPSHIRE", "NEW JERSEY", "NEW MEXICO", "NEW YORK", "NORTH DAKOTA", "OHIO", "OKLAHOMA", "OREGON", "PENNSYLVANIA", "RHODE ISLAND", "SOUTH CAROLINA", "SOUTH DAKOTA", "TENNESSEE", "TEXAS", "UTAH", "VERMONT", "VIRGINIA", "WASHINGTON", "WEST VIRGINIA", "WISCONSIN", "WYOMING"]
    
    var stateSelected : String = ""
    var userSelectedFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stateSelector.delegate = self
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        // Naturally choose California, makes the selector view more full
        let defaultStateIndex = stateArray.index(of: "CALIFORNIA")!
        stateSelector.selectRow(defaultStateIndex, inComponent: 0, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stateArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stateArray[row]
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
        }
    }
    
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
