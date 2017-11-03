//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit

//Global variables
struct GlobalVariables {
    static let blue = UIColor(red: 7, green: 196, blue: 203, alpha: 1.0)
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
    static let yellow = UIColor(red: 251/255, green: 213/255, blue: 7/255, alpha: 1.0)
    static let selectedColor = UIColor(red: 24/255, green: 186/255, blue: 192/255, alpha: 1.0)
    static let deselectedColor = UIColor.lightGray
    
}

//Extensions
extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
}

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

//Enums
enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}

enum MessageType {
    case photo
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}


extension UIViewController {
    
    
    func showAlert(message : String, title : String? = nil, completion: (() -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: ((title != nil) ? title! : "Trainers Society"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler:{
            action in
            if completion != nil {
                completion!()
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showAlertYesNo(message : String, title : String? = nil, actionNo: (() -> Swift.Void)? = nil, actionYes: (() -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: ((title != nil) ? title! : "Trainers Society"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:"No", style: .default, handler:{
            action in
            if actionNo != nil {
                actionNo!()
            }
        }))
        alert.addAction(UIAlertAction(title:"Yes", style: .default, handler:{
            action in
            if actionYes != nil {
                actionYes!()
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }

    func showAlertYesNo(message : String,
                        title : String? = nil,
                        yesTitle:String? = nil,
                        actionYes: (() -> Swift.Void)? = nil,
                        noTitle:String? = nil,
                        actionNo: (() -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: ((title != nil) ? title! : "Trainers Society"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title:((yesTitle != nil) ? yesTitle! : "Yes"), style: .default, handler:{
            action in
            if actionYes != nil {
                actionYes!()
            }
        }))
        alert.addAction(UIAlertAction(title:((noTitle != nil) ? noTitle! : "No"), style: .default, handler:{
            action in
            if actionNo != nil {
                actionNo!()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    func showAlertSignUp(message : String, title : String? = nil, actionCancel: (() -> Swift.Void)? = nil, actionOK: ((_ username: String) -> Swift.Void)? = nil){
        
        let alert = UIAlertController(title: ((title != nil) ? title! : "Trainers Society"), message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textfield) in
            textfield.placeholder = "Username"
        }
        
        alert.addAction(UIAlertAction(title:"Cancel", style: .default, handler:{
            action in
            if actionCancel != nil {
                actionCancel!()
            }
        }))
        alert.addAction(UIAlertAction(title:"OK", style: .default, handler:{
            action in
            if actionOK != nil {
                let username = alert.textFields?.first?.text
                actionOK!(username!)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }

    
    class func loadViewController(_ sbName: String, vcName: String) -> UIViewController {
        let sb = UIStoryboard(name: sbName, bundle: Bundle.main)
        let vc = sb.instantiateViewController(withIdentifier: vcName)
        
        return vc
    }
    
}

