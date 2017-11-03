//
//  MenuViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 1/12/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// MENU

import UIKit
import Material
import Firebase
import FirebaseStorage
import FirebaseDatabase


class MenuViewController: UIViewController, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var availabilityButton: UIButton!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var becomeTrainerButton: UIButton!
    
    var loggedInUser: AnyObject?
    var imagePicker = UIImagePickerController()
    var snapshot:NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view, typically from a nib.
        self.loggedInUser = Auth.auth().currentUser
        
        self.profilePicture.layer.cornerRadius = 50
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        self.profilePicture.clipsToBounds = true
        
        downloadProfilePic()
    }
    // Sets Profile Picture
    func downloadProfilePic() {
        
        DBProvider.Instance.usersRef.child(self.loggedInUser!.uid).observe(DataEventType.value, with: { (snapshot) in
            self.snapshot = snapshot.value as? NSDictionary
            
            self.username.text = self.snapshot!["name"] as? String
            if (self.snapshot!["trainer"] as? Bool)!{
                self.becomeTrainerButton.isHidden = true
                self.availabilityButton.isHidden = false
                self.searchButton.isHidden = true
            } else {
                self.availabilityButton.isHidden = true
                self.searchButton.isHidden = false
            }
            if(self.snapshot!["profile_pic"] != nil){
                self.profilePicture.sd_setImage(with: URL(string: (self.snapshot?["profile_pic"] as? String)!), placeholderImage: UIImage(named: "default-user-icon"))
            }

        })

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "hiw" {
            let navController = segue.destination as! UINavigationController
            let showHowItWorksViewController = navController.topViewController as! HowItWorksPageViewController
            
            showHowItWorksViewController.snapshot = snapshot
        }
    }

    
}
