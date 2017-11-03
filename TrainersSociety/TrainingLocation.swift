//
//  TrainingLocations.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 3/7/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// need init
// download all Locations
// Pass in filters?

import Foundation
import MapKit
import Firebase
import Contacts


class TrainingLocation: NSObject, MKAnnotation {
    
    var title: String? // Location Name
    var subtitle: String? // Trainer Name
    var trainerID: String?
    var locationID: String?
    var coordinate: CLLocationCoordinate2D

    
    init(title: String, subtitle: String, trainerID: String, locationID: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.trainerID = trainerID
        self.locationID = locationID
        self.coordinate = coordinate
    }
    
    //pass in userLocation
    class func downloadAllLocations(completion: @escaping ([TrainingLocation], Double) -> Swift.Void) {
        var locations = [TrainingLocation]()
        var loggedInUser = Auth.auth().currentUser
        var dis = 50.0
        
        DBProvider.Instance.locationRef.queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "lid")
            
            let address = (snapshot?["address"] as! String) + " " + (snapshot?["address2"] as! String) + " " + (snapshot?["city"] as! String) + ", " + (snapshot?["state"] as! String) + " " + (snapshot?["zip"] as! String)
            
            DBProvider.Instance.usersRef.child(snapshot?["trainer"] as! String).observe(.value, with: {(snapshot2) in
                let snapshot2 = snapshot2.value as? NSDictionary
                
                let location = TrainingLocation.init(title: snapshot?["name"] as! String, subtitle: snapshot2?["name"] as! String, trainerID: snapshot?["trainer"] as! String, locationID: snapshot?["lid"] as! String, coordinate: CLLocationCoordinate2D(latitude: snapshot?["latitude"] as! CLLocationDegrees, longitude: snapshot?["longitude"] as! CLLocationDegrees))
                
                DBProvider.Instance.usersRef.child((loggedInUser?.uid)!).observe(.value, with: { (snapshot3) in
                    // check filters then add
                    let snapshot3 = snapshot3.value as? NSDictionary
                    
                    if let filters = snapshot3?["filters"] as? NSDictionary {
                        dis = Double((filters["distance_filter"] as? String)!)!
                        let trainerPrice = snapshot2?["price"] as? String
                        let trainerSport = snapshot2?["sport"] as? String
                        
                        if let rating = snapshot2?["rating"] as? Int {
                            if let numRating = snapshot2?["numRating"] as? Int {
                                let trainerRating = Double(rating) / Double(numRating)
                                
                                if (Double((filters["rating_filter"] as? String)!)! <= Double(trainerRating)) && (Double((filters["price_filter"] as? String)!)! >= Double(trainerPrice!)!) {
                                    
                                    if (filters["sport_filter"] as? String)! == trainerSport {
                                        locations.append(location)
                                    } else if (filters["sport_filter"] as? String)! == "All" {
                                        locations.append(location)
                                    }
                                    
                                }
                                
                            }
                        } else if (Double((filters["rating_filter"] as? String)!)! < 1) {  //else if rating_filter is 0 show new trainers who have no rating
                            if (Double((filters["price_filter"] as? String)!)! >= Double(trainerPrice!)!) {
                                
                                if (filters["sport_filter"] as? String)! == trainerSport {
                                    locations.append(location)
                                } else if (filters["sport_filter"] as? String)! == "All" {
                                    locations.append(location)
                                }
                                
                            }

                        }

                    } else {
                        locations.append(location)

                    }
                
                    completion(locations, dis)

                })
                
            })
            
            
        })
    }
    
    
    // MARK: - MapKit related methods
    
    // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinTintColor() -> UIColor  {
        return MKPinAnnotationView.redPinColor()
    }
    
    // annotation callout opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
}
