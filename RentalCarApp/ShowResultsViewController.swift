//
//  CarSearchViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/23/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import Foundation
import UIKit

let apiKey = "IN0qI3YNFCPpCSQvqntxvGDn4RGp3Min"
let apiRental = "https://api.sandbox.amadeus.com/v1.2/cars/search-circle?apikey=\(apiKey)&"

class ShowResultsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var totalCars = 0
    var rentalDataArray: [(location: Location, address: Address, provider: Provider, cars: Cars)] = []
    var rowSelected = 0
    var providerSet : Set<String> = []
    var providerMap : [String: [Cars]] = [:]

    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carTableView: UITableView!
    @IBOutlet weak var totalCarsFoundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        getSearchResults()
        
        carTableView.delegate = self
        carTableView.dataSource = self
    }
    
    // MARK: Structs for JSON
    
    // Address properties
    struct Address : Decodable{
        let city: String?
        let country: String?
        let line1: String?
        
        init?(json: [String: Any]) {
            guard let city = json["city"] as? String,
                let country = json["country"] as? String,
                let line1 = json["line1"] as? String
                else {
                    return nil
                }
            self.city = city
            self.country = country
            self.line1 = line1
        }
    }
    
    // EstimatedTotal properties
    struct EstimatedTotal: Decodable {
        let amount : String?
        let currency : String?
     
        init?(json: [String: String]) {
            guard let amount = json["amount"],
                let currency = json["currency"]
            else {
                    return nil
            }
            self.amount = amount
            self.currency = currency
        }
    }
    
    // Price properties
    struct Price: Decodable {
        let amount : String?
        let currency : String?
        
        init?(json: [String: Any]) {
            guard let amount = json["amount"] as? String,
                let currency = json["currency"] as? String
            else {
                return nil
            }
            self.amount = amount
            self.currency = currency
        }
    }
    
    
    struct Rates : Decodable {
        let price: Price?
        
        init?(json: Array<[String: Any]>) {
            guard let price = json[0]["price"] as? [String: Any]
            else {
                return nil
            }
            self.price = Price(json: price)
        }
    }
    
    // VehicleInfo properties
    struct VehicleInfo : Decodable {
        let acriss_code: String?
        let air_conditioning: Int?
        let category: String?
        let fuel: String?
        let transmission: String?
        let type: String?
        
        init?(json: [String:Any]) {

            guard let acriss_code = json["acriss_code"] as? String,
                let air_conditioning = json["air_conditioning"] as? Int,
                let category = json["category"] as? String,
                let fuel = json["fuel"] as? String,
                let transmission = json["transmission"] as? String,
                let type = json["type"] as? String
                else {
                    return nil
                }
            
            self.acriss_code = acriss_code
            self.air_conditioning = air_conditioning
            self.category = category
            self.fuel = fuel
            self.transmission = transmission
            self.type = type
        }
    }
    
    // Cars properties
    struct Cars : Decodable {
        let estimated_total: EstimatedTotal?
        let rates: Rates?
        let vehicle_info: VehicleInfo?
        
        init?(json: [String: Any]) {
            guard let estimated_total = json["estimated_total"] as? [String: String],
            let rates = json["rates"] as? Array<[String: Any]>,
            let vehicle_info = json["vehicle_info"] as? [String:Any]
                else {
                    return nil
                }
            
            self.estimated_total = EstimatedTotal(json: estimated_total)
            self.rates = Rates(json: rates)
            self.vehicle_info = VehicleInfo(json: vehicle_info)
        }
    }
    
    // Location properties
    struct Location : Decodable {
        let latitude: Double?
        let longitude: Double?
        
        init?(json: [String:Any]) {
            guard let latitude = json["latitude"] as? Double,
                let longitude = json["longitude"] as? Double
                else {
                    return nil
                }
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    // Provider properties
    struct Provider : Decodable{
        let company_code: String?
        let company_name: String?
        
        init?(json: [String:Any]) {
            guard let company_code = json["company_code"] as? String,
                let company_name = json["company_name"] as? String
                else {
                    return nil
                }
            self.company_code = company_code
            self.company_name = company_name
        }
    }
    
    // MARK: Actions
    @IBAction func backButtonPushed(_ sender: Any) {
        if let navController = self.navigationController {
            for controller in navController.viewControllers {
                if controller is RadiusViewController {
                    navController.popToViewController(controller, animated:true)
                    break
                }
            }
        }
    }
    
    @IBAction func homeButtonPushed(_ sender: Any) {
        self.performSegue(withIdentifier: "HomeSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let carController = segue.destination as? CarDetailsViewController {
            carController.vehicleCategory = (self.rentalDataArray[self.rowSelected].cars.vehicle_info?.category)!
            carController.totalPrice = (self.rentalDataArray[self.rowSelected].cars.estimated_total?.amount)!
            carController.companyName = (self.rentalDataArray[self.rowSelected].provider.company_name)!
            carController.addressStreet = (self.rentalDataArray[self.rowSelected].address.line1)!
            carController.city = (self.rentalDataArray[self.rowSelected].address.city)!
            carController.transmission = (self.rentalDataArray[self.rowSelected].cars.vehicle_info?.transmission)!
            carController.bodyStyle = (self.rentalDataArray[self.rowSelected].cars.vehicle_info?.type)!
            carController.fuel = (self.rentalDataArray[self.rowSelected].cars.vehicle_info?.fuel)!
            carController.airConditioning = (self.rentalDataArray[self.rowSelected].cars.vehicle_info?.air_conditioning)!
            carController.location.latitude = (self.rentalDataArray[self.rowSelected].location.latitude)!
            carController.location.longitude = (self.rentalDataArray[self.rowSelected].location.longitude)!
            carController.dailyPrice = (self.rentalDataArray[self.rowSelected].cars.rates?.price?.amount)!
        }
        
    }
    
    // MARK: TableView
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(!self.providerMap.isEmpty)
        {
            return Array(self.providerMap.keys)[section]
        }
        else
        {
            return "Type"
        }
    }
        
    func numberOfSectionsInTableView(in tableView: UITableView) -> Int {
        if (self.providerSet.isEmpty) {
            return 1
        }
        else {
            return self.providerSet.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.totalCars
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = self.rentalDataArray[row].cars.vehicle_info?.category
        cell.detailTextLabel?.text = "$" + (self.rentalDataArray[row].cars.estimated_total?.amount)!

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.rowSelected = indexPath.row
        
        // Segue
        self.performSegue(withIdentifier: "ShowCarDetailsSegue", sender: self)
        
    }
    
    // MARK: Search Results
    
    func getSearchResults() {
        
        let parameters : String! = "latitude=\(RentalCarApp.location.latitude)&longitude=\(RentalCarApp.location.longitude)&radius=\(RentalCarApp.radius)&pick_up=\(RentalCarApp.pickupDateAsString)&drop_off=\(RentalCarApp.dropoffDateAsString)"
        
        let urlString = apiRental + parameters
        
        print (urlString)
        
        let dataTask = URLSession.shared.dataTask(with: URL.init(string: urlString)!) { (data, response, error) in
            if ((data) != nil)
            {
                let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String : Array<[String: Any]>]
                
                if (json?["results"]) == nil  {

                    let alert = UIAlertController(title: "Error", message: "Could not find any results. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {action in self.performSegue(withIdentifier: "HomeSegue", sender: self)}))
                    self.present(alert, animated: true)

                }
                
                else
                {
                    let branchesArray = json!["results"]
           
                    for eachBranch in branchesArray!
                    {
                        let location = Location(json: eachBranch["location"] as! [String : Any])
                        
                        let address = Address(json: eachBranch["address"] as! [String : Any])
                        
                        let provider = Provider(json: eachBranch["provider"] as! [String : Any])
                        
                        let carArray = eachBranch["cars"] as! Array<[String:Any]>
                        for cars in carArray {
                            
                            // Increment car count
                            self.totalCars+=1
                            
                            let carInfo = Cars(json: cars)
                            
                            self.rentalDataArray.append((location: location!, address: address!, provider: provider!, cars: carInfo!))
                            
                            var mapCarArray = self.providerMap[(provider?.company_name)!] ?? []
                            mapCarArray.append(carInfo!)
                            self.providerMap[(provider?.company_name)!!] = mapCarArray
                        }
                        
                        if (!self.providerSet.contains((provider?.company_name)!))
                        {
                            self.providerSet.insert((provider?.company_name)!)
                        }
                        

                    }


                    // Needs to be on main thread
                    DispatchQueue.main.async {
                        self.carTableView.reloadData()
                        self.loadingIndicator.stopAnimating()
                        self.totalCarsFoundLabel.text = "\(self.totalCars) CARS FOUND"
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
