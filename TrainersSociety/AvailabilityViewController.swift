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

class AvailabilityViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet var timeSlots: [UIButton]!

    let loggedInUser = Auth.auth().currentUser
    var availableDays = NSMutableDictionary()
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: ---------------- Initialize -------------------------
    func initialize () {
        
        // Setting up Navigation bar
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        let rootVC = self.navigationController?.viewControllers.first
        if rootVC == self {
            // Setting up menu button
            if revealViewController() != nil {
                menuButton.target = revealViewController()
                menuButton.action = "revealToggle:"
                
                view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
                view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
                
            }
        }else{
            self.navigationItem.setHidesBackButton(true, animated: false)
            let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
            let backButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(self.dismissSelf))
            navigationItem.leftBarButtonItem = backButton
            
        }
        
        // Setting up Calendar (FSCalendar)
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = true
       
        // Setting up TimeSlot buttons
        self.updateTimeSlots()
        
        // Getting your Available Days
        self.getAailableDays()
        
    }
    
    func getAailableDays () {
        
        // Get Days Available from User Data set Placeholder
        DBProvider.Instance.usersRef.child(self.loggedInUser!.uid).observe(.value, with: { (snapshot) in

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

        // setting up timeslot buttons as default
        for button in self.timeSlots {
            button.setTitleColor(GlobalVariables.deselectedColor, for: UIControlState.normal)
            button.borderColor = GlobalVariables.deselectedColor
        }
        
        // getting selected dates
        guard self.calendar.selectedDates.count > 0 else {return}
        
        // getting common timeslots
        guard let lastSelectedDate = self.calendar.selectedDate else { return }
        guard let stringDate = self.isAvailableDate(date: lastSelectedDate) else { return }
        guard let lastTimeSlots : NSDictionary = self.availableDays[stringDate] as? NSDictionary else { return }
       
        let commonTimeSlots = NSMutableArray()
        
        for time in lastTimeSlots.allKeys {
            guard let value = lastTimeSlots[time] as? Bool else { continue }
            guard value == true else { continue }
            
            var isCommon = true
            for selectedDate in self.calendar.selectedDates {
                guard selectedDate != lastSelectedDate else{ continue }
                guard let stringDate = self.isAvailableDate(date: selectedDate) else {
                    isCommon = false
                    break
                }
                guard let selectedTimeSlots : NSDictionary = self.availableDays[stringDate] as? NSDictionary else {
                    isCommon = false
                    break
                }
                
                var inIncluded = false
                for selectedTime in selectedTimeSlots.allKeys {
                    guard let selectedValue = selectedTimeSlots[selectedTime] as?  Bool else {break}
                    if time as! String == selectedTime as! String && selectedValue == true {
                        inIncluded = true
                        break
                    }
                }
                
                if inIncluded == true{
                    isCommon = true
                }else{
                    isCommon = false
                    break
                }
            }
            
            if isCommon == true {
                commonTimeSlots.add(time)
            }
        }
        
        // Setting up TimeSlot buttons
        for time in commonTimeSlots {
            for button in self.timeSlots {
                if button.currentTitle == time as? String {
                    button.setTitleColor(GlobalVariables.selectedColor, for: UIControlState.normal)
                    button.borderColor = GlobalVariables.selectedColor
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

    // MARK: ---------------- Action handler ----------------------
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }

    @IBAction func actionTimeSlots(_ sender: UIButton) {
        
        let currentColor = sender.titleColor(for: UIControlState.normal)
        if currentColor == GlobalVariables.selectedColor {
            sender.setTitleColor(GlobalVariables.deselectedColor, for: UIControlState.normal)
            sender.borderColor = GlobalVariables.deselectedColor
        }else{
            sender.setTitleColor(GlobalVariables.selectedColor, for: UIControlState.normal)
            sender.borderColor = GlobalVariables.selectedColor
        }
    }
    
    @IBAction func actionBook(_ sender: Any) {
        self.sendAvailabilityRequest()
    }
    
    func sendAvailabilityRequest() {
        guard let date = self.calendar.selectedDates.first else { return }
        let availables = NSMutableDictionary()
        for button in self.timeSlots {
            let currentColor = button.titleColor(for: UIControlState.normal)
            if currentColor == GlobalVariables.selectedColor {
                availables.setValue(true, forKey: button.currentTitle!)
            }
        }
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        self.sendAvailableDateRequest(date: date, times:availables) { (success) in
            hud.hide(animated: true)
            if success {
                for item in self.calendar.selectedDates {
                    self.calendar.deselect(item)
                }
                self.showAlert(message: "Your availability has now been updated.", title: "Schedule confirmed")
            }else {
                self.showAlert(message: "Failed to send the available days, please confirm your internet connection!")
            }
        }
        
    }
    
    func sendAvailableDateRequest(date : Date, times:NSDictionary, compelete : ((_ success: Bool) -> Swift.Void)? = nil){
        let stringDate = self.calendar.stringFrom(date: date, format: "yyyy-MM-dd")
        DBProvider.Instance.usersRef.child(self.loggedInUser!.uid).child("available_days").child(stringDate).setValue(times) { (error, refer) in
            if compelete != nil {
                if error != nil {
                    compelete!(false)
                }else {
                    if date == self.calendar.selectedDates.last {
                        compelete!(true)
                    }else{
                        let index = self.calendar.selectedDates.index(of: date)
                        let date = self.calendar.selectedDates[index! + 1]
                        self.sendAvailableDateRequest(date: date, times:times, compelete: compelete)
                    }
                }
            }
        }
        
    }

}


extension AvailabilityViewController : FSCalendarDataSource, FSCalendarDelegate{

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateTimeSlots()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        updateTimeSlots()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return (isAvailableDate(date: date) != nil) ? 1 : 0
    }

}

extension FSCalendar {
    func stringFrom(date: Date,  format:String) -> String
    {
        self.formatter.dateFormat = format;
        return self.formatter.string(from: date)
    }

    func dateFrom(string: String,  format:String) -> Date
    {
        self.formatter.dateFormat = format;
        return self.formatter.date(from: string)!
    }

}
