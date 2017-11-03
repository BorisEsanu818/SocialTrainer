//
//  MainViewController.swift
//  TrainersSociety
//
//  Created by Star on 9/19/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//

import UIKit
import Firebase


class MainViewController: SWRevealViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // showing profile alert in Trainer case when there are some missed info
        self.showProfileAlertInTrainerCase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func showProfileAlertInTrainerCase() {
        guard let loggedInUser = Auth.auth().currentUser else {return}

        DBProvider.Instance.usersRef.child(loggedInUser.uid).observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in
            guard let tempUserData = snapshot.value as? NSDictionary else{ return }
            guard let isTrainer = tempUserData["trainer"] as? Bool else{ return }
            
            if isTrainer == true {
                let sportName = tempUserData["sport"] as? String
                let price = tempUserData["price"] as? String
                let trainerLocations = tempUserData["locations"] as? NSArray

                var message : String?

                var tag = ""
                var invalidIndex = 0
                
                if sportName == nil {
                    message = "Please select your sport(field) of expertise."
                    tag = "\n-Sport"
                    invalidIndex += 1
                }
                if price == nil || Int(price!) == nil {
                    message = "Please add your hourly rate."
                    tag = tag + "\n-Hourly Rate"
                    invalidIndex += 1
                }
                if trainerLocations == nil || trainerLocations!.count == 0 {
                    message = "Please add at least 1 training location."
                    tag = tag + "\n-Training Location"
                    invalidIndex += 1
                }
                if invalidIndex > 1 {
                    message = "Please fill in the following fields before you go" + tag
                }else if invalidIndex == 1 {
                    message = message! + tag
                }

                if var error = message {
                    var title = "You forgot something!"
                    if let firstLogin = UserDefaults.standard.dictionary(forKey: "firstLogin") {
                        let first = firstLogin[Constants.FIRST_LOGIN] as? Bool
                        if first == nil || first == true {
                            title = "IMPORTANT!"
                            error = "Please take a few minutes to fill out your profile. If it is incomplete clients CAN't book a session with you." + tag
                        }
                    } else {
                        title = "IMPORTANT!"
                        error = "Please take a few minutes to fill out your profile. If it is incomplete clients CAN't book a session with you." + tag
                    }
                    
                    self.showAlert(message: error, title:title, completion:{
                        let storyboardSetting = UIStoryboard(name: "Settings", bundle: nil);
                        let naviSetting = storyboardSetting.instantiateInitialViewController() as! UINavigationController
                        
                        naviSetting.navigationBar.barTintColor = UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0)
                        naviSetting.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

                        let editProfile = storyboardSetting.instantiateViewController(withIdentifier: "EditProfile")
                        naviSetting.pushViewController(editProfile, animated: false)
                        self.pushFrontViewController(naviSetting, animated: true)
                        
                    })
                    
                    
                    
                }
                
            }
        })
        
        
    }

}
