//
//  CarSearchViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/23/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

let apiKey = ""
let apiRental = "https://api.sandbox.amadeus.com/v1.2/cars/search-circle?apikey=\(apiKey)&"

class ShowResultsViewController : UIViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // Parameters
    var radiusInKilometers = 32 // 20ish miles
    var pickUpDate = "2018-07-07"
    var dropOffDate = "2018-07-08"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        getSearchResults()
    }
    
    func getSearchResults() {
        
        let parameters : String! = "latitude=\(RentalCarApp.location.latitude)&longitude=\(RentalCarApp.location.longitude)&radius=\(RentalCarApp.radius)&pick_up=\(RentalCarApp.pickupDateAsString)&drop_off=\(RentalCarApp.dropoffDateAsString)"
        
        let urlString = apiRental + parameters
        
        print (urlString)
        
        let dataTask = URLSession.shared.dataTask(with: URL.init(string: urlString)!) { (data, response, error) in
            if ((data) != nil)
            {
                let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String:Any]
                
                if (json?["results"]) == nil  {
                    //                    fail((json?["message"] as? String) ?? "Unknown server error")
                    print(json?["message"])
                }
                else
                {
                    print(json?["results"])
                    
                    // Needs to be on main thread
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                    }
                    
                }
            }
            else
            {
            }
        }
        dataTask.resume()
    }
}
