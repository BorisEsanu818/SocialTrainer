//
//  VCCells.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 3/1/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
// TableView Cells
class senderCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.backgroundColor = GlobalVariables.blue
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

class receiverCell: UITableViewCell {
    
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var messageBackground: UIImageView!
    
    func clearCellData()  {
        self.message.text = nil
        self.message.isHidden = false
        self.messageBackground.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.message.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        self.messageBackground.layer.cornerRadius = 15
        self.messageBackground.clipsToBounds = true
    }
}

class conversationsTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func clearCellData()  {
        self.nameLabel.font = UIFont(name:"Montserrat-Regular", size: 17.0)
        self.messageLabel.font = UIFont(name:"Montserrat-Regular", size: 14.0)
        self.timeLabel.font = UIFont(name:"Montserrat-Regular", size: 13.0)
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
        self.messageLabel.textColor = UIColor.rbg(r: 111, g: 113, b: 121)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
    }
    
}
class findTrainerTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var trainerRating: CosmosView!
    
    func clearCellData()  {
        self.nameLabel.font = UIFont(name:"Montserrat-Regular", size: 17.0)
        self.sportLabel.font = UIFont(name:"Montserrat-Regular", size: 14.0)
        self.priceLabel.font = UIFont(name:"Montserrat-Bold", size: 12.0)
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
        self.sportLabel.textColor = UIColor.rbg(r: 111, g: 113, b: 121)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
    }
}
class sessionsTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func clearCellData()  {
        self.nameLabel.font = UIFont(name:"Montserrat-Regular", size: 17.0)
        self.locationLabel.font = UIFont(name:"Montserrat-Regular", size: 14.0)
        self.dateLabel.font = UIFont(name:"Montserrat-Regular", size: 10.0)
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
        self.locationLabel.textColor = UIColor.rbg(r: 111, g: 113, b: 121)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePic.layer.borderWidth = 2
        self.profilePic.layer.borderColor = GlobalVariables.yellow.cgColor
    }
}

class dashboardTBCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: RoundedImageView!
    
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var whoLabel: UILabel!
    
    func clearCellData()  {
        self.whenLabel.font = UIFont(name:"Montserrat-Regular", size: 14.0)
        self.locationTitle.font = UIFont(name:"Montserrat-Regular", size: 14.0)
        self.profilePic.layer.cornerRadius = 35
        self.profilePic.layer.borderColor = UIColor.white.cgColor
        self.profilePic.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
}

