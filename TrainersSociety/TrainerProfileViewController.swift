//
//  TrainerProfileViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 2/3/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// TRAINER PROFILE

import UIKit
import Firebase
import Cosmos
import SDWebImage
import Lightbox

class TrainerProfileViewController: UIViewController, sessionsFetchData {
    
    @IBOutlet weak var bio: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sport: UILabel!
    @IBOutlet weak var locations: UILabel!
    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var photoArrow: UIImageView!
    
    @IBOutlet var recentNames: [UILabel]!
    @IBOutlet var recentPics: [UIImageView]!
    @IBOutlet var trainerPics: [UIImageView]!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var constraintAboutSection: NSLayoutConstraint!
    
    private var sessions = [Sessions]();
    
    var recentSessions = [Sessions]();
    var loggedInUser: AnyObject?
    var loggedInUserData: NSDictionary?
    var otherUser: NSDictionary?
    var picArray:NSDictionary?
    var ratingAverage:Double?
    var locString = ""
    
    var profImg: UIImage?
    var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loggedInUser = Auth.auth().currentUser
        
        self.profilePicView.layer.cornerRadius = 50
        self.profilePicView.layer.borderColor = UIColor.white.cgColor
        self.profilePicView.clipsToBounds = true

        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: .plain, target: self, action: #selector(closeProfile))
        barButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = barButton
        
        self.chatButton.isEnabled = false
        self.photoArrow.isHidden = true
        // HIDE UNTIL FINDING RECENT CLIENTS
        for i in 0 ..< recentNames.count {
            recentNames[i].isHidden = true
            recentPics[i].isHidden = true
            trainerPics[i].isHidden = true
        }
        // Set Logged in User data in Dictionary
        DBProvider.Instance.usersRef.child(self.loggedInUser!.uid).observe(.value, with: { (snapshot) in
            self.loggedInUserData = snapshot.value as? NSDictionary
            
            self.loggedInUserData?.setValue(self.loggedInUser!, forKey: "uid")
        })
        // Get Trainer Ratings, Photos,
        DBProvider.Instance.usersRef.child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            let uid = self.otherUser?["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            self.otherUser?.setValue(uid, forKey: "uid")
                        
            if let rating = self.otherUser?["rating"] as? Int {
                if let numRating = self.otherUser?["numRating"] as? Int {
                    self.ratingView.rating = Double(rating) / Double(numRating)
                    self.numReviews.text = "( " + String(numRating) + " )"
                }
            }else {
                self.ratingView.rating = 0
                self.numReviews.text = "( 0 )"
            }
            self.ratingView.settings.updateOnTouch = false

            if self.otherUser!["photos"] as? NSDictionary != nil {
                let tap = UITapGestureRecognizer(target: self, action: Selector("photoViewTapped:"))
                self.photoView.addGestureRecognizer(tap)
                self.photoArrow.isHidden = false

                self.picArray = (self.otherUser!["photos"] as? NSDictionary)!
                
                if (self.picArray?.count)! > 3 {
                    for i in 0 ..< 3 {
                        if let pic = self.picArray?["photo" + String(i + 1)] as? String {
                            self.trainerPics[i].isHidden = false
                            self.trainerPics[i].sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "default-user-icon"))
                        }
                    }
                } else {
                    for i in 0 ..< (self.picArray?.count)! {
                        if let pic = self.picArray?["photo" + String(i + 1)] as? String {
                            self.trainerPics[i].isHidden = false
                            self.trainerPics[i].sd_setImage(with: URL(string: pic), placeholderImage: UIImage(named: "default-user-icon"))
                        }
                    }
                }
                
            }
            
        })
        
        // SET UI
        self.name.text = self.otherUser?["name"] as? String
        self.bio.text = self.otherUser?["bio"] as? String
        self.sport.text = self.otherUser?["sport"] as? String
        self.price.text = "$" + (self.otherUser?["price"] as? String)! + " /hr"
        
        self.name.sizeToFit()
        self.bio.sizeToFit()
        self.price.sizeToFit()
        
        if (self.otherUser?["profile_pic"] as? String) != nil {
            self.profilePicView.sd_setImage(with: URL(string: (self.otherUser?["profile_pic"] as? String)!), placeholderImage: UIImage(named: "default-user-icon"))
        }
        
        setLocationText(completion: { (state) in
            if state {
                self.locations.text = self.locString
                self.locations.sizeToFit()
            }
        })
        
        DBProvider.Instance.sessionsDelegate = self
        DBProvider.Instance.getSessions()
        // download trainer profile for Single Chat View (QuickChat)
        downloadChat()
    }
    
    func setLocationText(completion:@escaping (Bool)-> Void) {
        if let trainerLocations = self.otherUser?["locations"] as? NSArray {
            for loc in trainerLocations {
                DBProvider.Instance.locationRef.child(loc as! String).observe(.value, with: { (tloc) in
                    
                    let tloc = tloc.value as? NSDictionary
                    self.locString += "\u{2022} " + (tloc?["name"] as! String) + "\n"
                    
                    completion(true)
                })
            }
        }
    }
    func downloadChat() {
        DBProvider.Instance.usersRef.child(self.otherUser?["uid"] as! String).observe(.value, with: { (snapshot) in
            let uid = self.otherUser?["uid"] as! String
            self.otherUser = snapshot.value as? NSDictionary
            self.otherUser?.setValue(uid, forKey: "uid")
            
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
                let link = URL.init(string: "https://firebasestorage.googleapis.com/v0/b/trainers-society.appspot.com/o/users_prof%2Fdefault-user-icon.png?alt=media&token=61f405bf-99e3-47d5-ada4-e204160087d6")
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        if let profilePic = UIImage.init(data: data!) {
                            self.selectedUser = User.init(name: self.otherUser?["name"] as! String, email: self.otherUser?["email"] as! String, id: self.otherUser?["uid"] as! String, profilePic: profilePic)
                            DispatchQueue.main.async {
                                self.enableButton()
                                
                            }
                        } else {
                            self.selectedUser = User.init(name: self.otherUser?["name"] as! String, email: self.otherUser?["email"] as! String, id: self.otherUser?["uid"] as! String, profilePic: UIImage(named:"default-user-icon")!)
                            DispatchQueue.main.async {
                                self.enableButton()
                            }
                        }
                        
                        
                        
                    }
                }).resume()
            }
        })
    }
    // Get Sessions set Recent Client
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
                if (session.trainerID == otherUser?["uid"] as! String) {
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
            self.recentNames[i].text = self.recentSessions[i].client
            self.recentNames[i].sizeToFit()
            
            self.recentPics[i].isHidden = false
            self.recentPics[i].layer.cornerRadius = 20
            self.recentPics[i].layer.borderColor = UIColor.white.cgColor
            self.recentPics[i].clipsToBounds = true
            
            // set image
            DBProvider.Instance.usersRef.child(self.recentSessions[i].clientID).observe(.value, with: { (snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                
                if let profPic = snapshot?["profile_pic"] as? String {
                    self.recentPics[i].sd_setImage(with: URL(string: profPic), placeholderImage: UIImage(named: "default-user-icon"))
                }
            })
        }
    }

    private func setProfilePicture(imageView:UIImageView, imageToSet:UIImage){
        imageView.layer.cornerRadius = 50
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.image = imageToSet
    }
    
    @IBAction func didTapChat(_ sender: Any) {
        performSegue(withIdentifier: "trainerChatSegue", sender: nil)

    }
    @IBAction func didTapBook(_ sender: Any) {
         performSegue(withIdentifier: "toBookingView", sender: nil)
//                 performSegue(withIdentifier: "toBookingView1", sender: nil)
    }
    
    @IBAction func didTapAboutSection(_ sender: Any) {
        let realHeight = self.bio.text?.height(withConstrainedWidth: self.bio.frame.size.width, font: UIFont(name: "Montserrat-Regular", size: 13)!)
        let delta = Int(realHeight! - self.bio.frame.size.height)
        if (delta > 0){
            self.constraintAboutSection.constant += CGFloat(delta)
        }else{
            self.constraintAboutSection.constant = 120
        }
    }
    
    // Picture Viewer (LightBox)
    func photoViewTapped(_ sender: UITapGestureRecognizer) {
        var images = [LightboxImage]()
        for i in 0 ..< (self.picArray?.count)! {
            images.append(LightboxImage(imageURL: URL(string: (self.picArray?["photo" + String(i + 1)] as? String)!)!))
        }
        
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        
        present(controller, animated: true, completion: nil)
    }
    func closeProfile(){
        self.navigationController?.popViewController(animated: true);
    }
    func enableButton() {
        self.chatButton.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toBookingView" {
            let showBookingViewController = segue.destination as! TrainerBookingViewController
        
            showBookingViewController.otherUser = otherUser
        }
        if segue.identifier == "toBookingView1" {
            let showBookingViewController = segue.destination as! BookingViewController
            
            showBookingViewController.otherUser = otherUser
        }
        if segue.identifier == "trainerChatSegue" {
            let showConversationsViewController = segue.destination as! ChatViewController
            
            showConversationsViewController.currentUser = self.selectedUser
        }
   
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
