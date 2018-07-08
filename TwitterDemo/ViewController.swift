//
//  ViewController.swift
//  TwitterDemo
//
//  Created by ViJay Avhad on 08/07/18.
//  Copyright © 2018 ViJay Avhad. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {
    var screenName  = ""
    var TWLoggedInUser : TwitterUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let client = TWTRAPIClient.withCurrentUser()
        if let _ = client.userID{
            
            let loader = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            loader.center = self.view.center;
            loader.hidesWhenStopped = true
            self.view.addSubview(loader)
            loader.startAnimating()
            getUserEmail(client)
            
        }else{
            
            let logInButton = TWTRLogInButton(logInCompletion: { session, error in
                if (session != nil) {
                    
                    self.screenName = session!.userName
                    self.getUserEmail(TWTRAPIClient.withCurrentUser())
                } else {
                    print("error: \(String(describing: error?.localizedDescription))");
                    self.showAlert("\(String(describing: error!.localizedDescription))", title: "Error...")
                }
            })
            
            logInButton.center = self.view.center
            self.view.addSubview(logInButton)
        }
    }
    
    func getUserEmail(_ client: TWTRAPIClient){
        
        if let uId = client.userID{
            client.requestEmail { email, error in
                if (email != nil) {
                    client.loadUser(withID: uId) { (user, error) in
                        if user != nil{
                            
                            print(user!.name)
                            print(user!.screenName)
                            print(user!.profileImageURL)
                            print(user!.profileImageMiniURL)
                            print(user!.userID)
                            self.TWLoggedInUser =  TwitterUser(name: user!.name, email: email!, screenName: user!.screenName, hdImgUrl: user!.profileImageURL, sdImgUrl: user!.profileImageURL)
                            self.goToUserProfile(self.TWLoggedInUser!)
                            
                        }
                    }
                    
                } else {
                    self.showAlert("\(String(describing: error!.localizedDescription))", title: "Error...")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func goToUserProfile(_ user : TwitterUser){
        
        let userProfile = TWUserProfileVC.instantiate(fromAppStoryboard: .Main)
        userProfile.TWUser = self.TWLoggedInUser
        self.present(userProfile, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(_ message: String="Default message",title:String = ""){
        
        let alertController = UIAlertController(title: title,  message: message, preferredStyle:.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action -> Void in
        })
        self.present(alertController, animated: true, completion: nil)
    }
    
}

