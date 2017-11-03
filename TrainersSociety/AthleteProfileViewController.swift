//
//  AthleteProfileViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 4/24/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// ATHLETE PROFILE

import UIKit
import Firebase
import SDWebImage
import Lightbox

class AthleteProfileViewController: UIViewController, sessionsFetchData {
    
    private var sessions = [Sessions]();
    var clientID = ""
    var recentSessions = [Sessions]();
    var loggedInUser: AnyObject?
    var otherUser: NSDictionary?
    var picArray:NSDictionary?
    var selectedUser: User?

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var bio: UILabel!
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var photoArrow: UIImageView!
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet var clientPics: [UIImageView]!
    @IBOutlet var recentPics: [UIImageView]!
    @IBOutlet var recentNames: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loggedInUser = Auth.auth().currentUser

        self.profPicView.layer.cornerRadius = 50
        self.profPicView.layer.borderColor = UIColor.white.cgColor
        self.profPicView.clipsToBounds = true
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: .plain, target: self, action: #selector(closeProfile))
        barButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = barButton

        
        self.chatButton.isEnabled = false
        self.photoArrow.isHidden = true
        
        // HIDE UNTIL FINDING RECENT TRAINERS
        for i in 0 ..< recentNames.count {
            recentNames[i].isHidden = true
            recentPics[i].isHidden = true
            clientPics[i].isHidden = true
        }
        // GET PHOTOS
        DBProvider.Instance.usersRef.child(self.clientID).observe(.value, with: { (snapshot) in
            let uid = self.clientID
            self.otherUser = snapshot.value as? NSDictionary
            self.otherUser?.setValue(uid, forKey: "uid")
            
            if self.otherUser?["photos"] as? NSDictionary != nil {
                let tap = UITapGestureRecognizer(target: self, action: Selector("photoViewTapped:"))
                self.photoView.addGestureRecognizer(tap)
                self.photoArrow.isHidden = false
                
                self.picArray = (self.otherUser?["photos"] as? NSDictionary)!
                
                if (self.picArray?.count)! > 3 {
                    for i in 0 ..< 3 {
                        if let pic = self.picArray?["photo" + String(i + 1)] as? String {
                            self.clientPics[i].isHidden = false
                            self.clientPics[i].sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "default-user-icon"))
                        }
                    }
                } else {
                    for i in 0 ..< (self.picArray?.count)! {
                        if let pic = self.picArray?["photo" + String(i + 1)] as? String {
                            self.clientPics[i].isHidden = false
                            self.clientPics[i].sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "default-user-icon"))
                        }
                    }
                }
                
            }
            // SET UI
            self.name.text = self.otherUser?["name"] as? String
            self.bio.text = self.otherUser?["bio"] as? String
            
            self.name.sizeToFit()
            self.bio.sizeToFit()
            
            if (self.otherUser?["profile_pic"] as? String) != nil {
                self.profPicView.sd_setImage(with: URL(string: (self.otherUser?["profile_pic"] as? String)!), placeholderImage: UIImage(named: "default-user-icon"))
            }
            
            //download picture for chat segue
            if let temp_link = self.otherUser?["profile_pic"] as? String {
                let link = URL.init(string: temp_link)
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        if let profilePic = UIImage.init(data: data!) {
                            self.selectedUser = User.init(name: self.otherUser?["name"] as! String, email: self.otherUser?["email"] as! String, id: self.otherUser?["uid"] as! String, profilePic: profilePic)
                            DispatchQueue.main.async {
                                self.enableButton()
                            }
                        } else {
                            self.selectedUser = User.init(name: self.otherUser?["name"] as! String, email: self.otherUser?["email"] as! String, id: self.otherUser?["uid"] as! String, profilePic: UIImage(named: "default-user-icon")!)
                            
                            DispatchQueue.main.async {
                                self.enableButton()
                            }
                        }
                    }
                }).resume()
            } else {
                self.selectedUser = User.init(name: self.otherUser?["name"] as! String, email: self.otherUser?["email"] as! String, id: self.otherUser?["uid"] as! String, profilePic: UIImage(named:"default-user-icon")!)
                DispatchQueue.main.async {
                    self.enableButton()
                }
                
            }
        })
        
        DBProvider.Instance.sessionsDelegate = self
        DBProvider.Instance.getSessions()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    // LightBox Photo Viewer
    func photoViewTapped(_ sender: UITapGestureRecognizer) {
        var images = [LightboxImage]()
        for i in 0 ..< (self.picArray?.count)! {
            images.append(LightboxImage(imageURL: URL(string: (self.picArray?["photo" + String(i + 1)] as? String)!)!))
        }
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        
        present(controller, animated: true, completion: nil)
    }
    // Get Sessions set Recent Trainer
    func dataSessionsRecieved(sessions: [Sessions]) {
        self.sessions = sessions
        
        var temp = [Sessions]()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        var today = Date()
        let todayString = dateFormatter.string(from: today)
        var maxDate = dateFormatter.date(from: "0000/01/01")
        var mostRecent:Sessions?
        
        for session in sessions {
            if session.status == Constants.COMPLETED {
                if (session.clientID == otherUser?["uid"] as! String) {
                    temp.append(session)
                }
            }
            
        }
        
        temp.sort {
            var dateString = $0.date
            var date = dateFormatter.date(from: dateString)
            
            var dateString2 = $1.date
            var date2 = dateFormatter.date(from: dateString2)
            
            return date! > date2!
        }
        
        print(temp)
        if temp.count >= 3 {
            for i in 0...2 {
                if let s = temp[i] as? Sessions {
                    self.recentSessions.append(s)
                }
            }
        } else {
            self.recentSessions = temp
        }
        
        for i in 0 ..< self.recentSessions.count {
            self.recentNames[i].isHidden = false
            self.recentNames[i].text = self.recentSessions[i].trainer
            self.recentNames[i].sizeToFit()
            
            self.recentPics[i].isHidden = false
            self.recentPics[i].layer.cornerRadius = 20
            self.recentPics[i].layer.borderColor = UIColor.white.cgColor
            self.recentPics[i].clipsToBounds = true
            
            // set image
            DBProvider.Instance.usersRef.child(self.recentSessions[i].trainerID).observe(.value, with: { (snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                
                if let profPic = snapshot?["profile_pic"] as? String {
                    self.recentPics[i].sd_setImage(with: URL(string: profPic), placeholderImage: UIImage(named: "default-user-icon"))
                }
            })
        }
    }
    @IBAction func didPressChat(_ sender: Any) {
        performSegue(withIdentifier: "clientChatSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "clientChatSegue" {
            let showConversationsViewController = segue.destination as! ChatViewController
            
            showConversationsViewController.currentUser = self.selectedUser
        }
        
    }
    func closeProfile(){
        self.navigationController?.popViewController(animated: true);

    }
    func enableButton() {
        self.chatButton.isEnabled = true
    }
}
