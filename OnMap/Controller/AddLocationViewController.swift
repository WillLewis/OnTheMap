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
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addLocation(_ sender: Any) {
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
        print("calling getCorrdinate with \(String(describing: locationTextField.text))")
        UdacityClient.getCoordinate(addressString: locationTextField.text ?? "", completion: handleAddLocationResponse(success:error:))
        }
        

    
    func handleAddLocationResponse( success: Bool, error: Error?){
        
        if success{
            print("Latitude set to \(LocationDegrees.lat)")
            print("Longitude set to \(LocationDegrees.long)")
            UdacityClient.addStudentLocation(mapString: locationTextField.text, mediaURL: urlTextField.text, completion: locationSetFocus(success:error:))
            } else {
                showAddLocationFailure(message: error?.localizedDescription ?? "")
            }
    }
    
    /*If the orgin VC is the Map then after adding we center on new pin.
     If the origin VC is the Table then pop back to table */
    func locationSetFocus(success: Bool, error: Error?){
        if success{
            print("add location has been handled")
            //create a MKLocation using lat and long
            //store variable in mapview controller
            //set showsUserLocation = true
            if self.navigationController!.viewControllers.first is MapViewController {
                let controller: MapViewController
                controller = self.storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
                let addedLocation = CLLocation(latitude: LocationDegrees.lat, longitude: LocationDegrees.long)
                controller.centerLocation = addedLocation
                controller.isCentered = true
                navigationController?.pushViewController(controller, animated: true)
            } else {
               navigationController?.popToRootViewController(animated: true)
            }
        } else{
            showAddLocationFailure(message: error?.localizedDescription ?? "")
        }
    }
    /*
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        
        let controller = segue.destination as! MapViewController
        let addedLocation = CLLocation(latitude: LocationDegrees.lat, longitude: LocationDegrees.long)
        controller.centerLocation = addedLocation
        controller.isCentered = true
        print("prepare set centered to \(controller.centerLocation)")
        
    }
    */
    func showAddLocationFailure(message: String){
        DispatchQueue.main.async{
            let alertVC = UIAlertController(title: "AddLocation Failed", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.show(alertVC, sender: nil)
        }
    
    }
    
    

}
