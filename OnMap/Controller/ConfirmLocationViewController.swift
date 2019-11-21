//
//  ConfirmLocationViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/20/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
        var isCentered = false
        var centerLocation = CLLocation(latitude: 32.787663, longitude: -96.806163)
        var regionRadius: CLLocationDistance = 100000
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
           // self.mapView.addSubview(confirmButton)
            
            UdacityClient.getStudentLocations() {(data, error) in
                guard data != nil else {
                return
            }
            DispatchQueue.main.async {
                self.navigationItem.title = "Confirm Location"
                //self.mapView.delegate = self
                if self.isCentered{
                    self.centerMapOnLocation(location: self.centerLocation)
                }
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
            //self.mapView.delegate = self
            self.loadData()
            self.reloadInputViews()
            mapView.setUserTrackingMode(.follow, animated: true)
            // Do any additional setup after loading the view.
            mapView.showsUserLocation = false
            
            mapView.addSubview(confirmButton)
            confirmButton.layer.shadowOpacity = 0.8
            confirmButton.layer.shadowOffset = CGSize.zero
            confirmButton.sizeToFit()
            confirmButton.autoresizingMask = []
            confirmButton.backgroundColor = .systemTeal
        
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            self.isCentered = false
        }
        
        
    @IBAction func confirmLocation (_sender: Any) {
        UdacityClient.addStudentLocation(mapString: AddLocationViewController.Entry.mapEntry, mediaURL: AddLocationViewController.Entry.urlEntry, completion: handleConfirmLocation(success:error:))
        
        //dynamic change of text
        DispatchQueue.main.async{
            self.confirmButton.setTitle("LOCATION CONFIRMED", for: .normal)
        }
        //segue to map after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let detailVC = self.storyboard!.instantiateViewController(identifier: "MapViewController") as! MapViewController
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
      
        
    }
    func handleConfirmLocation(success: Bool, error: Error?){
        
        let controller: MapViewController
        controller = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        let addedLocation = CLLocation(latitude: LocationDegrees.lat, longitude: LocationDegrees.long)
        controller.centerLocation = addedLocation
        controller.isCentered = true
        navigationController?.pushViewController(controller, animated: true)
        
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
                DispatchQueue.main.async {
                   
                    self.mapView.addAnnotations(annotations)
                   // self.mapView.showAnnotations(annotations, animated: true)
                }
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
                pinView!.annotation = annotation
                pinView!.displayPriority = .required
                
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
        
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                mapView.setRegion(coordinateRegion, animated: true)
        }
        
        //dismiss navigation controller and tab bar
        
        
        
    }
