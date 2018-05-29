//
//  ViewController.swift
//  RentalCarApp
//
//  Created by Justin C. Lee on 5/19/18.
//  Copyright © 2018 Justin C. Lee. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    var dict : [String : AnyObject]!
    var fbUserDataSet = false
    var userDefaults = UserDefaults()
    let loginManager = FBSDKLoginManager()

    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var fbDescriptionLabel: UILabel!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.isNavigationBarHidden = true
        
        // FB
        self.configureFacebook()
        activityIndicatorView.hidesWhenStopped = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AccessToken.current != nil {
            // User is logged in, use 'accessToken' here
        }
        else {
            self.fbDescriptionLabel.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if (identifier == "HomeViewSegue" && self.fbUserDataSet == true) {
                let vc = segue.destination as? HomeViewController
                vc?.setFirstname(fname: dict["first_name"] as! String)
                vc?.setLastname(lname: dict["last_name"] as! String)
                vc?.setPicURL(urlString: ((dict["picture"] as! [String : AnyObject])["data"]?["url"]) as! String)
            }
        }
    }
    
    func configureFacebook()
    {
        loginButton.readPermissions = ["public_profile", "email", "user_friends"];
        loginButton.delegate = self
    }
    
    
    func getFBUserData(completion: @escaping (Bool) -> Void )
    {
        if((AccessToken.current) != nil){
            self.activityIndicatorView.startAnimating()
            FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "first_name, last_name, picture.type(large)"]).start(completionHandler: {(connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    self.fbUserDataSet = true
                    completion(true)
                }
            })
        }
    }
    
    /**
     Sent to the delegate when the button was used to login.
     - Parameter loginButton: the sender
     - Parameter result: The results of the login
     - Parameter error: The error (if any) from the login
     */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        self.getFBUserData(completion: {(success) -> Void in
            
            self.activityIndicatorView.stopAnimating()
            self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
        })
        fbDescriptionLabel.isHidden = true
    }
    
    /**
     Sent to the delegate when the button was used to logout.
     - Parameter loginButton: The button that was clicked.
     */
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        fbDescriptionLabel.isHidden = false
    }
    
    /**
     Sent to the delegate when the button is about to login.
     - Parameter loginButton: the sender
     - Returns: YES if the login should be allowed to proceed, NO otherwise
     */
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

}

