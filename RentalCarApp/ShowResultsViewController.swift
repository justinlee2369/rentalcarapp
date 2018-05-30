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

class ShowResultsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var totalCars = 0
    var rentalDataArray: [(location: Location, address: Address, provider: Provider, cars: Cars)] = []
    var rowSelected = 0
    var sortButtonPushedIndex : Int = 0

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var carTableView: UITableView!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var totalCarsFoundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize sort button pushed index
        self.sortButtonPushedIndex = 0
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        // Get results based off of user's settings
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
    
    // Rates properties
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
    
    // MARK: Sorting
    @IBAction func sortButtonPushed(_ sender: Any) {
        
        var buttonTitle = ""
        
        switch (self.sortButtonPushedIndex % 4) {
            // Ascending
            case 0:
                buttonTitle = "SORTED BY ASCENDING PRICE"
                self.rentalDataArray.sort(by: {sortRentalDataByAmount(provider1: $0.2, provider2: $1.2, car1: $0.3, car2: $1.3, ascending: true)})
                break
            // Descending
            case 1:
                buttonTitle = "SORTED BY DESCENDING PRICE"
                self.rentalDataArray.sort(by: {sortRentalDataByAmount(provider1: $0.2, provider2: $1.2, car1: $0.3, car2: $1.3, ascending: false)})
                break
            // Vehicle Category
            case 2:
                buttonTitle = "SORTED BY CATEGORY"
                self.rentalDataArray.sort(by: {sortRentalDataByCarCategory(provider1: $0.2, provider2: $1.2, car1: $0.3, car2: $1.3)})
                break
            // Company provider
            case 3:
                buttonTitle = "SORTED BY COMPANY"
                self.rentalDataArray.sort(by: {sortRentalDataByCompany(provider1: $0.2, provider2: $1.2, car1: $0.3, car2: $1.3)})
                break;
            default:
                self.carTableView.reloadData()
        }
        
        self.sortButtonPushedIndex+=1
        self.sortButton.setTitle(buttonTitle, for: .normal)
        self.carTableView.reloadData()
    }
    
    
    // Helper function to sort results in ascending or descending estimated total price
    func sortRentalDataByAmount(provider1: Provider, provider2: Provider, car1: Cars, car2: Cars, ascending: Bool) -> Bool
    {
        if let amount1 = car1.estimated_total?.amount {
            if let amount2 = car2.estimated_total?.amount {
                if let name1 = provider1.company_name {
                    if let name2 = provider2.company_name {
                        if (ascending) {
                            return (amount1 == amount2 ? name1 < name2 : amount1.localizedStandardCompare(amount2) == .orderedAscending)
                        }
                        else {
                            return (amount1 == amount2 ? name1 < name2 : amount1.localizedStandardCompare(amount2) == .orderedDescending)
                        }
                    }
                }
            }
        }
        return true
    }
    
    // Helper function to sort by car category
    func sortRentalDataByCarCategory(provider1: Provider, provider2: Provider, car1: Cars, car2: Cars) -> Bool
    {
        if let category1 = car1.vehicle_info?.category {
            if let category2 = car2.vehicle_info?.category {
                if let name1 = provider1.company_name {
                    if let name2 = provider2.company_name {
                        return (category1 == category2 ? name1 < name2 : category1.localizedStandardCompare(category2) == .orderedAscending)
                    }
                }
            }
        }
        return true
    }
    
    // Helper function to sort by rental company
    func sortRentalDataByCompany(provider1: Provider, provider2: Provider, car1: Cars, car2: Cars) -> Bool
    {
        if let amount1 = car1.estimated_total?.amount {
            if let amount2 = car2.estimated_total?.amount {
                if let name1 = provider1.company_name {
                    if let name2 = provider2.company_name {
                        return (name1 == name2 ? amount1 < amount2 : name1.localizedStandardCompare(name2) == .orderedAscending)
                    }
                }
            }
        }
        return true
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.totalCars
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath)
        
        let row = indexPath.row
        
        // Populate rental car data here
        cell.textLabel?.text = (self.rentalDataArray[row].cars.vehicle_info?.category)! + " by " + (self.rentalDataArray[row].provider.company_name)!
        cell.detailTextLabel?.text = "$" + (self.rentalDataArray[row].cars.estimated_total?.amount)!

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.rowSelected = indexPath.row
        
        // Segue to show details
        self.performSegue(withIdentifier: "ShowCarDetailsSegue", sender: self)
        
    }
    
    // MARK: Search Results
    
    func getSearchResults() {
        
        // Parameters to request data
        let parameters : String! = "latitude=\(RentalCarApp.location.latitude)&longitude=\(RentalCarApp.location.longitude)&radius=\(RentalCarApp.radius)&pick_up=\(RentalCarApp.pickupDateAsString)&drop_off=\(RentalCarApp.dropoffDateAsString)"
        
        let urlString = apiRental + parameters
        
        print (urlString)
        
        let dataTask = URLSession.shared.dataTask(with: URL.init(string: urlString)!) { (data, response, error) in
            if ((data) != nil)
            {
                // Convert json to dictionary
                let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String : Array<[String: Any]>]
                
                // Error, throw message
                if (json?["results"]) == nil  {
                    let alert = UIAlertController(title: "Error", message: "Could not find any results. Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {action in self.performSegue(withIdentifier: "HomeSegue", sender: self)}))
                    self.present(alert, animated: true)
                }
                // Useful data was returned
                else
                {
                    let branchesArray = json!["results"]
           
                    // Traverse through each branch of results
                    for eachBranch in branchesArray!
                    {
                        let location = Location(json: eachBranch["location"] as! [String : Any])
                        
                        let address = Address(json: eachBranch["address"] as! [String : Any])
                        
                        let provider = Provider(json: eachBranch["provider"] as! [String : Any])
                        
                        let carArray = eachBranch["cars"] as! Array<[String:Any]>
                        
                        // Traverse through each car option
                        for cars in carArray {
                            
                            // Increment car count
                            self.totalCars+=1
                            
                            let carInfo = Cars(json: cars)
                            
                            // Create rental data array
                            self.rentalDataArray.append((location: location!, address: address!, provider: provider!, cars: carInfo!))
                            
                            // By default, sort by company
                            self.rentalDataArray.sort(by: {self.sortRentalDataByCompany(provider1: $0.2, provider2: $1.2, car1: $0.3, car2: $1.3)})
                        }
                        
                    }

                    // Needs to be on main thread
                    DispatchQueue.main.async {
                        self.carTableView.reloadData()
                        self.loadingIndicator.stopAnimating()
                        self.totalCarsFoundLabel.text = "\(self.totalCars) CARS FOUND"
                        self.sortButton.setTitle("SORTED BY COMPANY", for: .normal)
                    }
                }
            }
            else {
            }
        }
        dataTask.resume()
    }
}
