//
//  CityViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/22/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class CityViewController : UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBAction func nextButtonPressed(_ sender: Any) {
        if (cityTextField.text == "") {
            let alert = UIAlertController(title: "", message: "City cannot be left blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            city = self.cityTextField.text!
            self.performSegue(withIdentifier: "ShowStateSegue", sender: self)
        }
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is AddressViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
}
