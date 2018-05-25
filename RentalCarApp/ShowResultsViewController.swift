//
//  CarSearchViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/23/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

class ShowResultsViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getSearchResults() {
        //GET /v1.2/cars/search-circle?apikey=IN0qI3YNFCPpCSQvqntxvGDn4RGp3Min&latitude=35.1504&longitude=-114.57632&radius=42&pick_up=2018-06-07&drop_off=2018-06-08
        let latitude = self.currentLocation.latitude
        let longitude = self.currentLocation.longitude
        
        let parameters : String! = "latitude=\(latitude)&longitude=\(longitude)&radius=\(self.radiusInKilometers)&pick_up=\(self.pickUpDate)&drop_off=\(self.dropOffDate)"
        
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
                }
            }
            else
            {
            }
        }
        dataTask.resume()
    }
}
