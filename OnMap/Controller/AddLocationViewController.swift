//
//  AddLocationViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/12/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    struct Entry{
        static var mapEntry = ""
        static var urlEntry = ""
    }
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
       //self.tabBarController?.dismiss(animated: false, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLocation(_ sender: Any) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        if self.locationTextField.text == "" {
         showAddLocationFailure(message: "Oh Cmon...give me a city and state")
        }
        guard let urlText = URL(string: urlTextField.text ?? "") else{
                return
        }
        let goodURL = UIApplication.shared.canOpenURL(urlText)
        if !goodURL {
            showAddLocationFailure(message: "should be something like https://www.hi.com")
            return
        }
        setPostLocationStruct()
        //print("calling getCorrdinate with \(String(describing: locationTextField.text))")
        UdacityClient.getCoordinate(addressString: locationTextField.text ?? "", completion: handleAddLocationResponse(success:error:))
        }
        

    
    func handleAddLocationResponse( success: Bool, error: Error?){
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        if success{
            //print("Latitude set to \(LocationDegrees.lat)")
            //print("Longitude set to \(LocationDegrees.long)")
            
            let controller: ConfirmLocationViewController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController") as! ConfirmLocationViewController
            let addedLocation = CLLocation(latitude: LocationDegrees.lat, longitude: LocationDegrees.long)
            controller.centerLocation = addedLocation
            controller.isCentered = true
            navigationController?.pushViewController(controller, animated: true)
            
            } else {
               showAddLocationFailure(message: "\(String(describing: error?.localizedDescription))")
            }
    }
    
    func setPostLocationStruct(){
        Entry.urlEntry = urlTextField.text ?? ""
        Entry.mapEntry = locationTextField.text ?? ""

    }

   
    func showAddLocationFailure(message: String){
        DispatchQueue.main.async{
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "AddLocation Failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil ))
            
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    
    

}
