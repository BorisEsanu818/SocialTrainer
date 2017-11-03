//
//  ViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 12/25/16.
//  Copyright © 2016 Trainers Society. All rights reserved.
//
//SIGN IN

import UIKit
import Material
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    // Login With Facebook
    @IBAction func fbLogin(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                DBProvider.Instance.usersRef.child(user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let snapshot = snapshot.value as? NSDictionary
                    
                    if(snapshot == nil)
                    {
                        DBProvider.Instance.saveUser(withID: user!.uid, name: user!.displayName!, email: user!.email!)
                        
                    }
                    // Present the main view
                    self.goToHome()
                    
                })
                
            })
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = Color.grey.darken4
        GIDSignIn.sharedInstance().uiDelegate = self
        
    }


    
    func goToHome(){
        
        let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    }

}

