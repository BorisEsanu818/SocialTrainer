//
//  AvailabilityViewController.swift
//  TrainersSociety
//
//  Created by Star on 8/11/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar
import Eureka
import OneSignal
import MBProgressHUD

class TrainerBookingViewController: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet var timeSlots: [UIButton]!
    
    let loggedInUser = Auth.auth().currentUser
    var availableDays = NSMutableDictionary()
    var bookedSessions = NSMutableDictionary();
    var otherUser: NSDictionary?
    
    var subView: BookingFormViewController?
    var location = ""
    var startTime = ""
    var endTime = ""
    var timePicked:String? = nil



    
    
    
    // MARK: --------------- ViewController Life cycle -------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Initailize
        self.initialize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "bookingForm" {
            let showBookingFormViewController = segue.destination as! BookingFormViewController
            
            showBookingFormViewController.otherUser = otherUser
            showBookingFormViewController.superView = self
            self.subView = showBookingFormViewController
        }
    }
    
    
    
    // MARK: ---------------- Initialize -------------------------
    func initialize () {
        
        // Setting up Navigation bar
        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: .plain, target: self, action: #selector(closeBooking))
        barButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = barButton
        
        // Setting up Calendar (FSCalendar)
        calendar.dataSource = self
        calendar.delegate = self
        calendar.select(Date())
        
        // Setting up TimeSlot buttons
        self.updateTimeSlots()
        
        // Getting Trainer Booked Sessions
        self.getBookedSessions()
        
        // Getting your Available Days
        self.getAailableDays()
        
        
    }
    
    func getBookedSessions() {
        
        // Get Booked Sessions from User
        DBProvider.Instance.sessionRef.queryOrdered(byChild: "trainerID").queryEqual(toValue: (self.otherUser!["uid"] as? String)!).observe(DataEventType.value, with: { (snapshot) in
            
            self.bookedSessions.removeAllObjects()
            guard let sessionData = snapshot.value as? NSDictionary else {
                self.updateUI()
                return
            }
            self.bookedSessions.setDictionary(sessionData as! [AnyHashable : Any])
            self.updateUI()
        })
    }
    
    func getAailableDays () {
       
        // Get Days Available from User Data set Placeholder
        DBProvider.Instance.usersRef.child((self.otherUser!["uid"] as? String)!).observe(DataEventType.value, with: { (snapshot) in
            
            self.availableDays.removeAllObjects()
            guard let tempUserData = snapshot.value as? NSDictionary else {
                self.updateUI()
                return
            }
            guard let aDays : NSDictionary = tempUserData["available_days"] as? NSDictionary else {
                self.updateUI()
                return
            }
            
            self.availableDays.setDictionary(aDays as! [AnyHashable : Any])
            self.updateUI()
        })
    }
    
    func updateUI () {
        // update calendar
        self.calendar.reloadData()
        
        // update timeslot buttons
        self.updateTimeSlots()
    }
    
    func updateTimeSlots() {
        
        for button in self.timeSlots {
            button.isEnabled = false
            button.setTitleColor(GlobalVariables.deselectedColor, for: UIControlState.normal)
            button.borderColor = GlobalVariables.deselectedColor
            button.backgroundColor = UIColor.white
        }
        
        guard let selectedDate = self.calendar.selectedDate else { return }
        guard let stringDate = self.isAvailableDate(date: selectedDate) else { return }
        guard let dic : NSDictionary = self.availableDays[stringDate] as? NSDictionary else { return }
        
        
        for time in dic.allKeys {
            guard let value = dic[time] as? Bool else { continue }
            for button in self.timeSlots {
                let isBookAvaialbe = self.isBookAvailableDate(date: selectedDate, time: time as? String) as! Bool
                if button.currentTitle == time as? String  && isBookAvaialbe {
                    if value == true {
                        button.isEnabled = true
                        button.setTitleColor(GlobalVariables.selectedColor, for: UIControlState.normal)
                        button.borderColor = GlobalVariables.selectedColor
                    }else{
                        button.setTitleColor(GlobalVariables.deselectedColor, for: UIControlState.normal)
                        button.borderColor = GlobalVariables.deselectedColor
                    }
                    break
                }
            }
        }
        
    }
    
    func isAvailableDate (date : Date ) -> String? {
        var result : String?
        let dateString = self.calendar.stringFrom(date: date, format: "yyyy-MM-dd")
        for key in self.availableDays.allKeys {
            guard let item = key as? String else { continue }
            if item == dateString {
                result = item
                break
            }
        }
        return result
    }
    
    func isBookAvailableDate (date : Date, time: String?) -> Bool? {
        var result : Bool;
        result = true;
        let dateString = self.calendar.stringFrom(date: date, format: "yyyy/MM/dd")
        for session in self.bookedSessions{
            let item = session.value as! NSDictionary
            let date = item["Date"] as? String
            let tmp = item["start"] as? String
            let start = passDataFormat(date: tmp!)
            let status = item["status"] as? String
            if date == dateString && start == time && status == "Confirmed" {
                result = false;
                break;
            }
        }
        return result;
    }
    
    func passDataFormat (date: String) -> String {
        var result: String = ""
        switch date {
        case "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM",
             "1:30 PM", "2:30 PM","3:30 PM","4:30 PM","5:30 PM","6:30 PM","7:30 PM","8:30 PM",
             "1:00 PM","2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM":
            result = "0" + date
            break
        default:
            result = date
            break
        }
        return result
    }
    
    // MARK: ---------------- Action handler ----------------------
    @IBAction func actionTimeSlots(_ sender: UIButton) {
        
        for button in self.timeSlots {
            if button.isEnabled == true {
                if button == sender {
                    
                    let currentColor = button.backgroundColor
                    if currentColor == GlobalVariables.selectedColor {
                        button.backgroundColor = UIColor.white
                        button.setTitleColor(GlobalVariables.selectedColor, for: UIControlState.normal)
                    }else{
                        button.backgroundColor = GlobalVariables.selectedColor
                        button.setTitleColor(UIColor.white, for: UIControlState.normal)
                    }
                    
                }else{
                    button.backgroundColor = UIColor.white
                    button.setTitleColor(GlobalVariables.selectedColor, for: UIControlState.normal)
                }
            }
        }

    }
    
    // Pass data to super view
    func passData(){
        
        if self.timePicked == nil { return }
        
        var endTime: String?
        
        // Calculate End Time and Get rid of 0 Prefix
        if (self.timePicked?.hasPrefix("0"))! && (self.timePicked?.characters.count)! > 1 {
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            self.timePicked = self.timePicked?.substring(from: index!)
        }
        
        switch self.timePicked! {
        case "12:30 PM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 2)
            endTime = self.timePicked?.substring(from: index!)
            endTime = String(1) + endTime!
            break
        case "12:00 PM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 2)
            endTime = self.timePicked?.substring(from: index!)
            endTime = String(1) + endTime!
            break
        case "11:30 AM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            var s = Array(String(describing: temp!).characters)
            endTime = self.replace(myString: endTime!, 1, s[0])
            endTime = self.replace(myString: endTime!, 6, "P")
            break
        case "11:00 AM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            var s = Array(String(describing: temp!).characters)
            endTime = self.replace(myString: endTime!, 1, s[0])
            endTime = self.replace(myString: endTime!, 6, "P")
            break
        case "10:30 AM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            var s = Array(String(describing: temp!).characters)
            endTime = self.replace(myString: endTime!, 1, s[0])
            break
        case "10:00 AM":
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            var s = Array(String(describing: temp!).characters)
            endTime = self.replace(myString: endTime!, 1, s[0])
            break
        case "9:30 AM":
            var index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 0)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked?.substring(from: index!)
            endTime = String(temp!) + endTime!
            break
        case "9:00 AM":
            var index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 0)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 1)
            endTime = self.timePicked?.substring(from: index!)
            endTime = String(temp!) + endTime!
            break
        default:
            let index = self.timePicked?.index((self.timePicked?.startIndex)!, offsetBy: 0)
            endTime = self.timePicked!
            var temp = Int(String((endTime?[index!])!))
            temp = temp! + 1
            var s = Array(String(describing: temp!).characters)
            endTime = self.replace(myString: endTime!, 0, s[0])
            break
        }
        print(self.timePicked!)
        print(endTime!)
        
        self.startTime = self.timePicked!
        self.endTime = endTime!
    }
    
    // Make times uniform
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    @IBAction func actionBook(_ sender: Any) {
        
        for button in self.timeSlots {
            if button.isEnabled == true {
                let currentColor = button.backgroundColor
                if currentColor == GlobalVariables.selectedColor {
                    self.timePicked = button.titleLabel?.text
                    self.passData()
                    self.sendBookingRequest()
                    break
                }
            }
        }
        
    }
    
    // Send booking request
    func sendBookingRequest() {
        
        guard self.timePicked != nil else {
            showAlert(message:"Please select your timeslots")
            return
        }
        if location == "Pick a Location" || location == "" {
            showAlert(message:"Please select a location")
            return
        }
        
        guard let selectedDate = self.calendar.selectedDate else { return }
        let stringDate = self.calendar.stringFrom(date: selectedDate, format: "yyyy/MM/dd")
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        DBProvider.Instance.locationRef.queryOrdered(byChild: "trainer").observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in
            
            hud.hide(animated: true)
            if let locationData = snapshot.value as? NSDictionary {
                for (key, value) in locationData {
                    if let temp = value as? [String:Any] {
                        if (temp["trainer"] as! String == self.otherUser?["uid"] as! String) {
                            if(temp["name"] as! String == self.location) {
                                let locationID = key as! String

                                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                                DBProvider.Instance.locationRef.child(locationID).observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in

                                    hud.hide(animated: true)
                                    let temp = snapshot.value as? NSDictionary
                                    let address = (temp?["address"] as! String) + " " + (temp?["address2"] as! String) + " " + (temp?["city"] as! String) + ", " + (temp?["state"] as! String) + " " + (temp?["zip"] as! String)
                                    
                                    let data: Dictionary<String, Any> = ["client": self.loggedInUser?.displayName,
                                                                         "trainer": self.otherUser!["name"]!,
                                                                         "clientID": self.loggedInUser!.uid,
                                                                         "trainerID": self.otherUser!["uid"]!,
                                                                         "Date": stringDate,
                                                                         "start": self.startTime,
                                                                         "end": self.endTime,
                                                                         "location": self.location,
                                                                         "address": address,
                                                                         "price": self.otherUser!["price"]!,
                                                                         "status": "Pending"];
                                    
                                    let session = DBProvider.Instance.sessionRef.childByAutoId()

                                    let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                                    session.setValue(data){ (error, refer) in
                                    
                                        hud.hide(animated: true)
                                        if error != nil {
                                            self.showAlert(message: "Failed to send the booking request, please check your network connection!")
                                        }else {
                                            self.sendNotification()
                                            self.showAlert(message: "Booking Request Sent!")
                                        }
                                    }
                                })
                                
                            }
                        }
                    }
                }
            }
        })
    }

    // Send Notification (OneSignal)
    func sendNotification(){
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let pushToken = status.subscriptionStatus.pushToken
        
        if pushToken != nil && otherUser?["onesignal_ids"] != nil {
            let message = (self.loggedInUser?.displayName!)! + " has sent a session request!"
            let notificationContent = [
                "include_player_ids": otherUser?["onesignal_ids"] as? [String],
                "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                "headings": ["en": ""],
                "subtitle": ["en": ""],
                "ios_badgeType": "Increase",
                "ios_badgeCount": 1
                ] as [String : Any]
            
            OneSignal.postNotification(notificationContent)
        }
    }

    // Update booked Value
    func updateBookedSlot(){
        
    }
    
    func closeBooking(){
        self.navigationController?.popViewController(animated: true);
        
    }
    
}

extension TrainerBookingViewController : FSCalendarDataSource, FSCalendarDelegate{
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateTimeSlots()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return (isAvailableDate(date: date) != nil) ? 1 : 0
    }
    
}
