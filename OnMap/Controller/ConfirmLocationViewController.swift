//
//  ConfirmLocationViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/20/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {

   
    @IBOutlet weak var mapView: MKMapView!
        
        
        private var floatingConfirmButton: UIButton?
        private static let buttonHeight: CGFloat = 40.0
        private static let buttonWidth: CGFloat = 310.0
        private let trailingValue: CGFloat = -15.0
        private let leadingValue: CGFloat = 15.0
        private let leadingBottomValue: CGFloat = 30.0
        private let shadowRadius: CGFloat = 2.0
        private let shadowOpacity: Float = 0.5
        private let shadowOffset = CGSize(width: 0.0, height: 5.0)
        private let scaleKeyPath = "scale"
        private let animationKeyPath = "transform.scale"
        private let animationDuration: CFTimeInterval = 0.2
        private let animateFromValue: CGFloat = 1.00
        private let animateToValue: CGFloat = 1.02
    
        var isCentered = false
        var centerLocation = CLLocation(latitude: 32.787663, longitude: -96.806163)
        var regionRadius: CLLocationDistance = 100000
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            mapView.delegate = self
            self.tabBarController?.tabBar.isHidden = true
            
            createFloatingButton()
            
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
                /*
                self.mapView.addSubview(self.confirmButton)
                    self.confirmButton.layer.shadowOpacity = 0.8
                self.confirmButton.layer.shadowOffset = CGSize.zero
                    self.confirmButton.sizeToFit()
                self.confirmButton.autoresizingMask = []
                self.confirmButton.backgroundColor = .systemTeal*/
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
            //addFloatingButtonObj()
        }
        
    
        override func viewWillDisappear(_ animated: Bool) {
            
                DispatchQueue.main.async {
                    guard self.floatingConfirmButton?.superview != nil else {  return }
                    self.floatingConfirmButton?.removeFromSuperview()
                    self.floatingConfirmButton = nil
                    self.isCentered = false
                }
            super.viewWillDisappear(false)
        }
    
    
    func createFloatingButton(){
        floatingConfirmButton = UIButton(type: .custom)
        floatingConfirmButton?.translatesAutoresizingMaskIntoConstraints = false
        floatingConfirmButton?.backgroundColor = .systemTeal
        floatingConfirmButton?.setTitle("CONFIRM LOCATION", for: .normal)
        //floatingConfirmButton?.center = self.view.center
        floatingConfirmButton?.addTarget(self, action: #selector(self.didPressConfirm), for: .touchUpInside)
        //floatingConfirmButton?.centerXAnchor.constraint(equalTo: ((parent?.view.centerXAnchor)!)).isActive = true
        constrainFloatingButtonToWindow()
        addShadowToFloatingButton()
        addScaleAnimationToFloatingButton()
    }
        
    @objc func didPressConfirm (_sender: Any) {
        UdacityClient.addStudentLocation(mapString: AddLocationViewController.Entry.mapEntry, mediaURL: AddLocationViewController.Entry.urlEntry, completion: handleConfirmLocation(success:error:))
        
        //dynamic change of text
        DispatchQueue.main.async{
            self.floatingConfirmButton?.setTitle("LOCATION CONFIRMED", for: .normal)
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
    
    func constrainFloatingButtonToWindow() {
        DispatchQueue.main.async {
            let margins = self.view.layoutMarginsGuide
            
            guard let keyWindow = UIApplication.shared.keyWindow,
                let floatingConfirmButton = self.floatingConfirmButton else { return }
            keyWindow.addSubview(floatingConfirmButton)
            //keyWindow.trailingAnchor.constraint(equalTo: floatingConfirmButton.trailingAnchor, constant: self.trailingValue).isActive = true
            keyWindow.bottomAnchor.constraint(equalTo: floatingConfirmButton.bottomAnchor, constant: self.leadingBottomValue).isActive = true
            
            floatingConfirmButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: self.trailingValue).isActive = true
            floatingConfirmButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: self.leadingValue).isActive = true
            //floatingConfirmButton.widthAnchor.constraint(equalToConstant: ConfirmLocationViewController.buttonWidth).isActive = true
            floatingConfirmButton.heightAnchor.constraint(equalToConstant: ConfirmLocationViewController.buttonHeight).isActive = true
        
        }
    }
    func addShadowToFloatingButton() {
        floatingConfirmButton?.layer.shadowColor = UIColor.black.cgColor
        floatingConfirmButton?.layer.shadowOffset = shadowOffset
        floatingConfirmButton?.layer.masksToBounds = false
        floatingConfirmButton?.layer.shadowRadius = shadowRadius
        floatingConfirmButton?.layer.shadowOpacity = shadowOpacity
    }
    
    func addScaleAnimationToFloatingButton() {
        // Add a pulsing animation to draw attention to button:
        DispatchQueue.main.async {
            let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: self.animationKeyPath)
            scaleAnimation.duration = self.animationDuration
            scaleAnimation.repeatCount = .greatestFiniteMagnitude
            scaleAnimation.autoreverses = true
            scaleAnimation.fromValue = self.animateFromValue
            scaleAnimation.toValue = self.animateToValue
            self.floatingConfirmButton?.layer.add(scaleAnimation, forKey: self.scaleKeyPath)
        }
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
