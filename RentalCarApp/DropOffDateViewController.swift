//
//  DropOffDateViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/23/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class DropOffDateViewController : UIViewController {
    
    @IBOutlet weak var dropOffDatePicker: UIDatePicker!
    
    var pickupDate = Date()
    
    override func viewDidLoad() {
        dropOffDatePicker.datePickerMode = UIDatePickerMode.date
        
        // Min date can't be less than pickup date
        dropOffDatePicker.minimumDate = pickupDate as Date
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        RentalCarApp.dropoffDateAsString = dateFormatter.string(from: self.dropOffDatePicker.date)
        
        // Segue to distance selector
        self.performSegue(withIdentifier: "ShowRadiusSegue", sender: self)
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is PickUpDateViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
}
