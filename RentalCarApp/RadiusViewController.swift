//
//  RadiusViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/24/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class RadiusViewController : UIViewController {
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceInfoLabel.text = getValueFromSlider() + " miles"
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is DropOffDateViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
        distanceInfoLabel.text = getValueFromSlider() + " miles"
    }
    
    @IBAction func doneButtonPushed(_ sender: Any) {
        
        // Convert miles to kilometers for API parameter usage
        // Set global variable
        RentalCarApp.radius = milesToKilometers(miles: getValueFromSlider())
        
        // Start search loading
        
        
        // After, segue to results
        self.performSegue(withIdentifier: "ShowResultsSegue", sender: self)
    }
    
    func getValueFromSlider() -> String
    {
        let distanceValue = Int(distanceSlider.value)
        return distanceValue.description
    }
    
    func milesToKilometers(miles: String) -> String
    {
        let km = Int(Double(miles)! * 1.6)
        return km.description
    }
}
