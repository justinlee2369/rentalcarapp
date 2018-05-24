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
        dropOffDatePicker.minimumDate = pickupDate as Date
    }
    
    @IBAction func doneButtonPushed(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        RentalCarApp.dropoffDateAsString = dateFormatter.string(from: self.dropOffDatePicker.date)
    }
}
