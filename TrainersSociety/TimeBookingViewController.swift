//
//  TimeBookingViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 4/27/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// EMBEDDED TRAINER TIME SLOT BOOKING VIEW

import UIKit
import Firebase

class TimeBookingViewController: UIViewController {
    
    let loggedInUser = Auth.auth().currentUser
    let weekdays = [
        "sunday",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday"
    ]
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    var superView: BookingViewController?
    var otherUser: NSDictionary?
    
    var dayPicked:String? = nil
    var timePicked:String? = nil
    var availableDays = [String]()
    var availableTimes = [UIButton]()
    @IBOutlet var timeSlots: [UIButton]!
    // Clicked on a Time Slot
    @IBAction func timeButtonPressed(sender: UIButton) {
        self.timePicked = sender.titleLabel!.text
        
        for t in availableTimes {
            if t.titleLabel!.text != self.timePicked {
                t.setTitleColor(UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0), for: .normal)
                t.backgroundColor = UIColor.white
            }
        }
        
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0)
        
        self.passData()
    }
    // Make times uniform
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString.characters)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    // Disable times not set by trainer
    func disableTimes(){
        for t in timeSlots {
            t.isEnabled = false
            t.setTitleColor(UIColor.lightGray, for: .normal)
            t.borderColor = UIColor.lightGray
        }
        
    }
    // Enable times set by trainer
    func enableTimes(){
    
        for t in self.availableTimes {
            t.isEnabled = true
            t.borderColor = UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0)
            t.setTitleColor(UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0), for: .normal)
            t.backgroundColor = UIColor.white
            
        }
        
    }
    
    // Pass data to super view
    func passData(){
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
        print(self.dayPicked)

        self.superView?.startTime = self.timePicked!
        self.superView?.endTime = endTime!
    }
    // Get today's date
    func getDay() {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let findDate = formatter.date(from: self.dayPicked!)
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: findDate!)
        
        self.dayPicked = weekdays[weekDay - 1]
        
        if (self.availableDays.contains(self.dayPicked!)){
            enableTimes()
        }else {
            disableTimes()
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        disableTimes()
        // Get Trainers available days and times
        DBProvider.Instance.usersRef.child((self.otherUser!["uid"] as? String)!).observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in
            let tempUserData = snapshot.value as? NSDictionary
            var thirty:NSDictionary?
            var trainerTimes = [String]()
            
            if tempUserData!["available_days"] as? NSDictionary != nil {
                self.availableDays = (tempUserData!["available_days"] as? NSDictionary)?.allKeys as! [String]
            }
            
            if tempUserData!["time_intervals"] as? NSDictionary != nil {
                thirty = tempUserData!["time_intervals"] as? NSDictionary
            }
            
            if tempUserData!["available_times"] as? NSDictionary != nil {
                trainerTimes = (tempUserData!["available_times"] as? NSDictionary)?.allKeys as! [String]
                if (thirty?["30min"] as? Bool)! {
                    for s in trainerTimes {
                        trainerTimes.append(self.replace(myString: s as! String, 3, "3"))
                    }
                }
                for i in 0 ..< trainerTimes.count {
                    for j in 0 ..< self.timeSlots.count {
                        if trainerTimes[i] as? String == self.timeSlots[j].titleLabel?.text {
                            self.availableTimes.append(self.timeSlots[j])
                            
                        }
                    }
                }
            }
            self.dayPicked = self.dateFormatter.string(from: Date())
            self.getDay()
        })
        
    }
}

