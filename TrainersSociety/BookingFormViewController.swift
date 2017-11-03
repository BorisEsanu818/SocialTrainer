//
//  BookingFormViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 2/19/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// EMBEDDED FORM FOR TRAINER LOCATIONS

import UIKit
import Eureka
import Firebase

class BookingFormViewController: FormViewController {
    
    var otherUser: NSDictionary?
    var superView: TrainerBookingViewController?
    
    var locationArray:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var counter = 0;
        self.tableView?.backgroundColor = UIColor.white

        DBProvider.Instance.locationRef.queryOrdered(byChild: "trainer").observe(.childAdded, with: { (snapshot) in
            let snapshot = snapshot.value as? NSDictionary
            
            
            if(snapshot!["trainer"] as? String == self.otherUser!["uid"] as? String){
                var temp = snapshot!["name"] as? String!
                
                
                self.locationArray.append(temp!)
            }

            if(self.locationArray.count == (self.otherUser!["locations"] as? NSArray)?.count) && (counter < 1){
                counter = counter + 1
                self.form +++ Section("")
                    <<< PopoverSelectorRow<String>("Location") {
                        $0.title = "Location"
                        $0.options = self.locationArray
                        $0.value = "Pick a Location"
                        $0.selectorTitle = "Choose a Location"
                    }.onChange { [weak self] row in
                            self!.passData()
                    }
                self.passData()
            }
        })
        
        
    }
    
    func passData(){
        let valueDict = self.form.values()
        print(valueDict)
        
        if let locUnpick = valueDict["Location"] as? String {
            self.superView?.location = valueDict["Location"] as! String
        }else {
            self.superView?.location = "Pick a Location"
        }
        
    }

}
