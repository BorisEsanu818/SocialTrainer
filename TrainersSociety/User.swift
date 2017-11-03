//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit
import Firebase

class User: NSObject {
    
    //MARK: Properties
    let name: String
    let email: String
    let id: String
    var profilePic: UIImage
    
    //MARK: Methods
    class func registerUser(withName: String, email: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                user?.sendEmailVerification(completion: nil)
                
                let userInfo = ["email" : email, "password" : password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                
                DBProvider.Instance.saveUser(withID: user!.uid, name: withName, email: email)
                let changeRequest = user?.createProfileChangeRequest()
                
                changeRequest?.displayName = withName
                changeRequest?.commitChanges { error in
                    if let error = error {
                        // An error happened.
                    } else {
                        // Profile updated.
                        print("saved")
                    }
                }
                
                completion(true)
                
//                Database.database().reference().child("users").child((user?.uid)!).child("credentials").updateChildValues(values, withCompletionBlock: { (errr, _) in
//                    if errr == nil {
//                        let userInfo = ["email" : email, "password" : password]
//                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
//                        completion(true)
//                    }
//                })
            }
            else {
                completion(false)
            }
        })
    }
    
   class func loginUser(withEmail: String, password: String, completion: @escaping (Bool) -> Swift.Void) {
    Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email": withEmail, "password": password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userInformation")
            completion(true)
        } catch _ {
            completion(false)
        }
    }
    
   class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
    Database.database().reference().child("Users").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if let data = snapshot.value as? NSDictionary {
                let name = data["name"] as! String
                let email = data["email"] as! String
                
                var link = URL.init(string: "https://firebasestorage.googleapis.com/v0/b/trainers-society.appspot.com/o/users_prof%2Fdefault-user-icon.png?alt=media&token=61f405bf-99e3-47d5-ada4-e204160087d6")
                if let temp_link = data["profile_pic"] as? String {
                    link = URL.init(string: data["profile_pic"]! as! String)
                }
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        if let profilePic = UIImage.init(data: data!){
                            let user = User.init(name: name, email: email, id: forUserID, profilePic: profilePic)
                            completion(user)

                        } else {
                            let user = User.init(name: name, email: email, id: forUserID, profilePic: UIImage(named:"default-user-icon")!)
                            completion(user)

                        }
                       
                    }
                }).resume()
            }
        })
    }
    
    class func downloadAllUsers(exceptID: String, completion: @escaping (User) -> Swift.Void) {
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            let id = snapshot.key
            let data = snapshot.value as! [String: Any]
            let credentials = data["credentials"] as! [String: String]
            if id != exceptID {
                let name = credentials["name"]!
                let email = credentials["email"]!
                let link = URL.init(string: credentials["profilePicLink"]!)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = User.init(name: name, email: email, id: id, profilePic: profilePic!)
                        completion(user)
                    }
                }).resume()
            }
        })
    }
    
    class func checkUserVerification(completion: @escaping (Bool) -> Swift.Void) {
        Auth.auth().currentUser?.reload(completion: { (_) in
            let status = (Auth.auth().currentUser?.isEmailVerified)!
            completion(status)
        })
    }

    
    //MARK: Inits
    init(name: String, email: String, id: String, profilePic: UIImage) {
        self.name = name
        self.email = email
        self.id = id
        self.profilePic = profilePic
    }
}

