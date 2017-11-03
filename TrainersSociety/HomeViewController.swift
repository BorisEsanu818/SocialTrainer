//
//  HomeViewController.swift
//  TrainersSociety
//
//  Created by Boris Esanu on 1/9/17.
//  Copyright © 2017 Trainers Society. All rights reserved.
//
// MAP VIEW

import UIKit
import Firebase
import MapKit
import Presentr

class HomeViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var search: UISearchBar!
    
    let locationManager = CLLocationManager()
    let trainingSearchTable = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
    var locationPinArray = [TrainingLocation]()
    var selectedPinLocation: NSDictionary?
    var resultSearchController:UISearchController? = nil
    
    //Presentr for Filter View
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = TransitionType.coverHorizontalFromRight
        return presenter
    }()
    
    lazy var filterViewController: FilterViewController = {
        let filterViewController = self.storyboard?.instantiateViewController(withIdentifier: "FilterViewController")
        return filterViewController as! FilterViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

        }
        
        self.mapView.showsCompass = false

        NotificationCenter.default.addObserver(self, selector: #selector(sendFilterData), name: NSNotification.Name(rawValue: "callFilter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(goToListView), name: NSNotification.Name(rawValue: "callListView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchBarCancelButtonClicked), name: NSNotification.Name(rawValue: "callCancel"), object: nil)
        
        getLocations()

        resultSearchController = UISearchController(searchResultsController: trainingSearchTable)
        resultSearchController?.searchResultsUpdater = trainingSearchTable
        resultSearchController?.isActive = true

        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        self.resultSearchController?.searchResultsController?.view.addObserver(self, forKeyPath: "hidden", options: [], context: nil)
        self.resultSearchController?.searchBar.delegate = self
        self.resultSearchController?.delegate = self
        
        trainingSearchTable.mapView = mapView

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        super.touchesBegan(touches, with: event);
    }
    // Open Filter on Press
    @IBAction func didTapFilter(_ sender: Any) {
        bottomHalfDefault()
    }
    func bottomHalfDefault() {
        presenter.presentationType = .bottomHalf
        
        presenter.transitionType = nil
        presenter.dismissTransitionType = nil
        
        presenter.dismissAnimated = true
        customPresentViewController(presenter, viewController: filterViewController, animated: true, completion: nil)
    }
    // Open Search Bar
    @IBAction func didTouchSearchBar(_ sender: Any) {
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search Trainers"
        navigationItem.titleView = searchBar

        navigationItem.titleView = resultSearchController?.searchBar
        self.resultSearchController?.searchBar.becomeFirstResponder()
    }
    // Show Search Bar on Button Press
    func willPresentSearchController(searchController: UISearchController) {
            self.resultSearchController?.searchResultsController?.view.isHidden = false
    }
    //Get rid of Search Bar on Cancel Click
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.titleView = nil
    }
    // Update search controller
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let someView: UIView = object as! UIView? {
            
            if (someView == self.resultSearchController?.searchResultsController?.view &&
                (keyPath == "hidden") &&
                (resultSearchController?.searchResultsController?.view.isHidden)! &&
                (resultSearchController?.searchBar.isFirstResponder)!) {

                resultSearchController?.searchResultsController?.view.isHidden = false
            }
            
        }
    }
    // Get all Locations according to filter and add annotations to map
    func getLocations(){
            
        TrainingLocation.downloadAllLocations(completion: { (locations, distanceFilter) in
            var annLocations = locations
            if let userCord = self.locationManager.location?.coordinate {
                let userLoc = CLLocation(latitude: userCord.latitude, longitude: userCord.longitude)
                for loc in annLocations {
                    let locLoc = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    let distance = userLoc.distance(from: locLoc)/1609.344 // in miles

                    if distance > distanceFilter {
                        annLocations.remove(at: annLocations.index(of: loc)!)
                    }
                }
            }
            self.mapView.addAnnotations(annLocations)
            self.trainingSearchTable.locations = annLocations

        })

    }
    // Change Map based on filter change
    func sendFilterData(){
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        getLocations()
    }
    
    func goToListView() {
        self.performSegue(withIdentifier: "FindTrainer", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToTrainer" {
            let showTrainerProfileViewController = segue.destination as! TrainerProfileViewController
            
            let user = self.selectedPinLocation
            showTrainerProfileViewController.otherUser = user
        }
    }
    // Bring map view to user location
    @IBAction func didPressMyLocation(_ sender: Any) {
        self.mapView.setCenter(self.mapView.userLocation.coordinate, animated: true)
        let region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 5000, 5000)
        mapView.setRegion(region, animated: true)
    }
}
// Map Delegate and Annotation Methods
extension HomeViewController : MKMapViewDelegate {
    // 1
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? TrainingLocation {
            let identifier = "locationPin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named:"tlocation")
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 20)))
                button.setBackgroundImage(UIImage(named: "forward"), for: UIControlState())
                view.rightCalloutAccessoryView = button as UIView
            }
//            view.pinTintColor = annotation.pinTintColor()
            return view
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let gesture = UITapGestureRecognizer(target: self, action:#selector(annotationTapped(sender:)))
        view.addGestureRecognizer(gesture)
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
    func mapView(_ mapView: MKMapView!, didAdd views: [MKAnnotationView]!) {
        
        for view in views {
            if (view.annotation?.isKind(of: MKUserLocation.self))! {
                view.canShowCallout = false
            }
        }
        
    }
    func annotationTapped(sender: UITapGestureRecognizer){
        let view = sender.view as! MKAnnotationView
        let location = view.annotation as! TrainingLocation
        
        DBProvider.Instance.usersRef.child((location.trainerID)!).observe(.value, with: { (snapshot) in
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "uid")
            
            self.selectedPinLocation = snapshot
            self.performSegue(withIdentifier: "goToTrainer", sender: nil)
        })
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! TrainingLocation
        
        DBProvider.Instance.usersRef.child((location.trainerID)!).observe(.value, with: { (snapshot) in
            let key = snapshot.key
            let snapshot = snapshot.value as? NSDictionary
            snapshot?.setValue(key, forKey: "uid")
            
            self.selectedPinLocation = snapshot
            self.performSegue(withIdentifier: "goToTrainer", sender: nil)
        })
        
    }
}
extension HomeViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: (error)")
    }
}

