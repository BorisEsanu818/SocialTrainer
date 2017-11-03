//
//  HowItWorksViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 1/12/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// HOW IT WORKS VIEW Mainly for MENU Button

import UIKit
import Material
import Firebase


class HowItWorksViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = Color.grey.darken4
        if revealViewController() != nil {

            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

