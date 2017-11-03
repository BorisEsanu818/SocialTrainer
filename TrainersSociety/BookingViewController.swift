//
//  BookingViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 2/16/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// BOOKING VIEW

import UIKit
import Firebase
import FSCalendar
import Eureka
import OneSignal

class BookingViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate{

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var bookingForm: UIView!
    
    var subView: BookingFormViewController?
    var subView2: TimeBookingViewController?

    var otherUser: NSDictionary?
    var startTime = ""
    var endTime = ""
    var location = ""
    var locationID = ""
    var selectedDate = ""
    var selectedDay = ""
    
    let loggedInUser = Auth.auth().currentUser
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    // Embedded View
    let bookForm = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "bookingForm")
    let weekdays = [
        "sunday",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: .plain, target: self, action: #selector(closeBooking))
        barButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = barButton
        
        // Setting up Calendar (FSCalendar)
        calendar.dataSource = self
        calendar.delegate = self

        self.calendar.select(Date())
        selectedDate = self.dateFormatter.string(from: Date())
        getDay()
    
    }
    // Send booking request
    @IBAction func didTapBook(_ sender: Any) {
        print(self.loggedInUser?.uid, self.otherUser?["uid"], selectedDate , startTime, endTime, location)
        
        if location == "Pick a Location" || location == "" {
            alert(message: "Please Fill All Fields", title: "Error")
            return
        }
        
        DBProvider.Instance.locationRef.queryOrdered(byChild: "trainer").observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in
            
            if let locationData = snapshot.value as? NSDictionary {
                for (key, value) in locationData {
                    if let temp = value as? [String:Any] {
                        if (temp["trainer"] as! String == self.otherUser?["uid"] as! String) {
                            if(temp["name"] as! String == self.location) {
                                self.locationID = key as! String
                                
                                DBProvider.Instance.locationRef.child(self.locationID).observeSingleEvent(of:.value, with: { (snapshot:DataSnapshot) in
                                    let temp = snapshot.value as? NSDictionary
                                    
                                    let address = (temp?["address"] as! String) + " " + (temp?["address2"] as! String) + " " + (temp?["city"] as! String) + ", " + (temp?["state"] as! String) + " " + (temp?["zip"] as! String)
        
                                    let data: Dictionary<String, Any> = ["client": self.loggedInUser?.displayName,
                                                                         "trainer": self.otherUser!["name"]!,
                                                                         "clientID": self.loggedInUser!.uid,
                                                                         "trainerID": self.otherUser!["uid"]!,
                                                                         "Date": self.selectedDate,
                                                                         "start": self.startTime,
                                                                         "end": self.endTime,
                                                                         "location": self.location,
                                                                         "address": address,
                                                                         "price": self.otherUser!["price"]!,
                                                                         "status": "Pending"];
                                
                                    let session = DBProvider.Instance.sessionRef.childByAutoId()
                                    session.setValue(data)
                                })
                                self.sendNotification()
                                self.alert(message: "Booking Request Sent!", title: "")
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
    // Segue data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "bookingForm" {
            let showBookingFormViewController = segue.destination as! BookingFormViewController
            
            showBookingFormViewController.otherUser = otherUser
//            showBookingFormViewController.superView = self
            self.subView = showBookingFormViewController
        }
        if segue.identifier == "timeForm" {
            let showTimeBookingViewController = segue.destination as! TimeBookingViewController
            
            showTimeBookingViewController.otherUser = otherUser
            showTimeBookingViewController.superView = self
            self.subView2 = showTimeBookingViewController
        
        }
    }
    
    func closeBooking(){
        self.navigationController?.popViewController(animated: true);

    }
    // FSCalendar Delegate Methods
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        selectedDate = selectedDates[0]
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        getDay()
    }
    func getDay() {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let findDate = formatter.date(from: self.selectedDate)
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: findDate!)
        
        self.selectedDay = weekdays[weekDay - 1]
        
        passDataToTimeBooking()
    }
    
    func passDataToTimeBooking(){
        subView2?.dayPicked = self.selectedDay
        
        if (subView2?.availableDays.contains(self.selectedDay))!{
            subView2?.enableTimes()
        }else {
            subView2?.disableTimes()
        }
    }
}
extension BookingViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        if title == "" {
            OKAction = UIAlertAction(title: "OK", style: .default, handler: {action in self.closeBooking()})
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


