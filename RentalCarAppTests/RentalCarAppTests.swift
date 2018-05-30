//
//  RentalCarAppTests.swift
//  RentalCarAppTests
//
//  Created by Justin C. Lee on 5/19/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import XCTest
@testable import RentalCarApp

class RentalCarAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGoodResponse() {
        let expectation = XCTestExpectation(description: "Some data from API")
        let url = URL.init(string: "https://api.sandbox.amadeus.com/v1.2/cars/search-circle?apikey=\(RentalCarApp.apiKey)&latitude=-117.8483067&longitude=33.6670534&radius=15&pick_up=2018-06-05&drop_off=2018-06-07")
        
        let response = URLSession.shared.dataTask(with: url!) {(data, _, _) in
            XCTAssertNotNil(data)
            expectation.fulfill()
        }
        
        response.resume()
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testInvalidLongitude() {
        
        let showResultsVC = ShowResultsViewController()

        RentalCarApp.location.latitude = -117.8483067
        RentalCarApp.location.longitude = 33.6670534
        RentalCarApp.radius = "15"
        RentalCarApp.pickupDateAsString = "2018-06-05"
        RentalCarApp.dropoffDateAsString = "2018-06-07"
        
        showResultsVC.getSearchResults()
        // Don't expect data since invalid longitude input
        assert(showResultsVC.rentalDataArray.isEmpty)
        
    }
    
    func testSettersHomeVC() {
        let homeVC = HomeViewController()
        homeVC.setLastname(lname: "Lee")
        homeVC.setFirstname(fname: "Justin")
        
        XCTAssertEqual(RentalCarApp.firstname, "Justin")
        XCTAssertEqual(RentalCarApp.lastname, "Lee")
        
        homeVC.setPicURL(urlString: "http://www.google.com")
        XCTAssertEqual(RentalCarApp.profilePicURL, "http://www.google.com")
    }
    
}
