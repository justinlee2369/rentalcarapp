//
//  CarDetailsViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/28/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class CarDetailsViewController : UIViewController {
    
    var vehicleCategory: String = ""
    var price: String = ""
    var companyName: String = ""
    
    var addressStreet: String = ""
    var city: String = ""
    
    var location = CLLocationCoordinate2D()
    
    var transmission: String = ""
    var bodyStyle: String = ""
    var fuel: String = ""
    
    var airConditioning : Int = 1
    
    // MARK: IBOutlets
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var bodyStyleLabel: UILabel!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var airConditioningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewComponents()
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is ShowResultsViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func navigateButtonPushed(_ sender: Any) {
        
    }
    
    func setViewComponents() {
        self.categoryLabel.text = vehicleCategory
        self.priceLabel.text = "$\(price)"
        self.companyLabel.text = companyName
        self.transmissionLabel.text = transmission
        self.bodyStyleLabel.text = bodyStyle
        self.fuelLabel.text = fuel
        self.addressLabel.text = "\(addressStreet)\n\(city)"
        
        if (airConditioning == 1) {
            self.airConditioningLabel.text = "Yes"
        }
        else {
            self.airConditioningLabel.text = "No"
        }
    }
}
