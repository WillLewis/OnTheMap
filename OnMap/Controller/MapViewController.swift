//
//  FirstViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/7/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UdacityClient.getStudentLocations() {(data, error) in
            guard data != nil else {
            return
            
        }
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: LocationDegrees.lat, longitude: LocationDegrees.long)
        
        DispatchQueue.main.async {
            self.navigationItem.title = "Map of Locations"
            let add  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
            let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reLoad))
            self.navigationItem.rightBarButtonItems = [add, reload]
            self.loadData()
            self.reloadInputViews()
        }
        }
        
    }
    /*
    override func loadView(){
        mapView = MKMapView()
        mapView.delegate = self
        
    }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func addTapped(for segue: UIStoryboardSegue, _ sender: UIBarButtonItem){
           if segue.identifier == "mapToAdd" {
               let detailVC = segue.destination as! AddLocationViewController
               detailVC.title = "Add Location"
           }
    }
    
    @objc func reLoad(){
        loadData()
    }
    
    func loadData(){
        UdacityClient.getStudentLocations() {(data, error) in
            guard let data = data else {
                return
                
            }
            var annotations = [MKPointAnnotation]()
            LocationModel.locations = data
            
            for location in data{
                let lat = CLLocationDegrees(location.latitude)
                let long = CLLocationDegrees(location.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let firstMapName = location.firstName ?? ""
                let lastMapName = location.lastName ?? ""
                let mapMediaUrl = location.mediaURL ?? " "
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(String(describing: firstMapName)) \(String(describing: lastMapName))"
                annotation.subtitle = mapMediaUrl
                annotations.append(annotation)
            }
            self.mapView.addAnnotations(annotations)
        }
    }
    // MARK: - MKMapViewDelegate
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .systemTeal
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            if let toOpen = view.annotation?.subtitle! {
                UIApplication.shared.open(URL(string: toOpen)!)
            }
        }
    }
    
}

