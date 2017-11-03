//
//  AvailabilityTableViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 5/3/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// AVAILABILITY TABLE VIEW

import UIKit
import Firebase


class AvailablityTableViewController: UITableViewController {
    
    @IBOutlet var availabilitySettings: UITableView!

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.03, green:0.77, blue:0.80, alpha:1.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
            
        }
        
        
    }
    
    
}

