//
//  AddressViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/22/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class AddressViewController : UIViewController {
    
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextButtonPushed(_ sender: Any) {
        // Redirect user to use skip button
        if (addressTextField.text == "") {
            let alert = UIAlertController(title: "Not sure what your address is?", message: "That's fine! Just select skip if you're unsure.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else {
            address = self.addressTextField.text!
            print(address)
            self.performSegue(withIdentifier: "SegueToCityView", sender: self)
        }
    }
    
    // Allow users to skip entering address in case they don't know exact location
    @IBAction func skipButtonPushed(_ sender: Any) {
        address = ""
        self.performSegue(withIdentifier: "SegueToCityView", sender: self)
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
