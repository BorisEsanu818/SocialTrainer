//
//  BecomeATrainerViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 1/12/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//

import UIKit
import Firebase
import Material
import SwiftMailgun

class BecomeATrainerViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    // Mailgun
    let mailgun = MailgunAPI(apiKey: "key-84bfb1742cc10a0e0760dea45abfce60", clientDomain: "sandbox097f484ffa834d31acb484671a0f2a51.mailgun.org")
    let loggedInUser = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Color.grey.darken4
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

        }
        
        
    }
   // Send Email to Admin that user logged in wants to be a trainer
    @IBAction func agreeButtonPressed(_ sender: Any) {
        mailgun.sendEmail(to: "support@trainerssociety.net", from: "Trainers Society <test@sandbox097f484ffa834d31acb484671a0f2a51.mailgun.org>", subject: "Become a Trainer", bodyHTML: "<h3>\(loggedInUser!.displayName!) would like to become a trainer.</h3><h3>Info: \(loggedInUser!.email!), \(loggedInUser!.uid)</h3>", completionHandler: { result in
            print(result)
            if result.success {
                print("Email sent")
                self.alert(message: "Our team will review your request and send you an email within 24 hours.", title:"Thank you")
            }
        })
    }
    
    func email() {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.mailgun.net/v3/sandbox097f484ffa834d31acb484671a0f2a51.mailgun.org/messages")! as URL)
        
        request.httpMethod = "POST"
        let credentials = "api:key-84bfb1742cc10a0e0760dea45abfce60"
        request.setValue("Basic \(credentials.toBase64())", forHTTPHeaderField: "Authorization")
        
        let data = "from: Swift Email <(mailgun@sandbox097f484ffa834d31acb484671a0f2a51.mailgun.org)>&to: [ats353@gmail.com,(ats353@gmail.com)]&subject:Hello&text:Testing_some_Mailgun_awesomness"
        request.httpBody = data.data(using: String.Encoding.ascii)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let error = error {
                print(error)
            }
            if let response = response {
                print("url = \(response.url!)")
                print("response = \(response)")
                let httpResponse = response as! HTTPURLResponse
                print("response code = \(httpResponse.statusCode)")
            }
        })
        task.resume()
    }
    
}
extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
extension BecomeATrainerViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
