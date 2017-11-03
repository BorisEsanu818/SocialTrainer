//
//  SignUpViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 4/14/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// SIGN UP

import UIKit
import Material
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class SignUpViewController: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var signUpTitle: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet var warningLabels: [UILabel]!
    @IBOutlet var inputFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = Color.grey.darken4
        
        self.signUpTitle.addCharactersSpacing(spacing: 5, text: "TRAINERS SOCIETY")
        self.signUpTitle.font = UIFont(name:"Montserrat-Regular", size: 12.0)
        self.signUpTitle.sizeToFit()
        
        self.emailField.setLeftPaddingPoints(10)
        self.nameField.setLeftPaddingPoints(10)
        self.passwordField.setLeftPaddingPoints(10)

        GIDSignIn.sharedInstance().uiDelegate = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    // Register a User
    @IBAction func didPressRegister(_ sender: Any) {
        for item in self.inputFields {
            item.resignFirstResponder()
        }
        User.registerUser(withName: self.nameField.text!, email: self.emailField.text!, password: self.passwordField.text!) { [weak weakSelf = self] (status) in
            DispatchQueue.main.async {
                for item in self.inputFields {
                    item.text = ""
                }
                if status == true {
                    Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                         self.goToHome()
                    }
                } else {
                    for item in (weakSelf?.warningLabels)! {
                        item.isHidden = false
                    }
                }
            }
        }
    }
    // Register with Facebook
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
    func goToHome(){
        
        let vc = UIStoryboard(name: "Menu", bundle: nil).instantiateInitialViewController()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = vc
    }


}
extension UILabel {
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
