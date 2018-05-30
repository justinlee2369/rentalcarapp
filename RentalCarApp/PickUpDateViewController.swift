//
//  PickUpDateViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/23/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class PickUpDateViewController : UIViewController {
    @IBOutlet weak var pickupDatePicker: UIDatePicker!
    
    var pickupDate = Date()
    
    override func viewDidLoad() {
        
        // Get the date
        let currentDate = Date()
        
        pickupDatePicker.datePickerMode = UIDatePickerMode.date

        // Limit to today's current date
        pickupDatePicker.minimumDate = currentDate as Date
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        RentalCarApp.pickupDateAsString = dateFormatter.string(from: pickupDatePicker.date)
        self.pickupDate = pickupDatePicker.date
        
        self.performSegue(withIdentifier: "DropOffDateSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            print (identifier)
            if (identifier == "DropOffDateSegue") {
                let vc = segue.destination as? DropOffDateViewController
                vc?.pickupDate = self.pickupDate
            }
        }
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is HomeViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
}
