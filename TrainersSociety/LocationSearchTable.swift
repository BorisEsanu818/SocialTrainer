//
//  LocationSearchTable.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 4/16/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// SEARCH TABLE FOR MAP SEARCH

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var locations = [TrainingLocation]()
    var matchingItems:[TrainingLocation] = []

    var mapView: MKMapView? = nil
}
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    // tableView methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.subtitle
        cell.detailTextLabel?.text = selectedItem.title
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row]
        mapView?.centerCoordinate = selectedItem.coordinate
        mapView?.selectAnnotation(selectedItem, animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callCancel"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}
// Update Search text compare with matching items
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

        guard let searchBarText = searchController.searchBar.text else { return }
        filterContent(searchText: searchBarText)
    }
    func filterContent(searchText:String) {
        self.matchingItems = self.locations.filter { location in
            let trainerName = location.subtitle
            return(trainerName?.lowercased().contains(searchText.lowercased()))!
        }
        self.tableView.reloadData()
    }
}

