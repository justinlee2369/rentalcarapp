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
import MapKit

class CarDetailsViewController : UIViewController {
    
    // Rental logistics
    var vehicleCategory: String = ""
    var dailyPrice : String = ""
    var totalPrice: String = ""
    var companyName: String = ""
    
    // Location data
    var addressStreet: String = ""
    var city: String = ""
    var location = CLLocationCoordinate2D()
    
    // Car features
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
    @IBOutlet weak var dailyPriceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewComponents()
    }
    
    // MARK: Actions
    
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
    
    // Get user directions from current location to chosen rental center
    @IBAction func navigateButtonPushed(_ sender: Any) {
        let coordinate = CLLocationCoordinate2DMake(self.location.latitude, self.location.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = companyName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    // Helper function to setup view
    func setViewComponents() {
        self.categoryLabel.text = vehicleCategory
        self.priceLabel.text = "$\(totalPrice)"
        self.companyLabel.text = companyName
        self.transmissionLabel.text = transmission
        self.bodyStyleLabel.text = bodyStyle
        self.fuelLabel.text = fuel
        self.addressLabel.text = "\(addressStreet)\n\(city)"
        self.dailyPriceLabel.text = "$\(dailyPrice)"
        
        if (airConditioning == 1) {
            self.airConditioningLabel.text = "Yes"
        }
        else {
            self.airConditioningLabel.text = "No"
        }
    }
}
