//
//  AddLocationViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/12/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit

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
        UdacityClient.getCoordinate(addressString: self.urlTextField.text ?? "", completion: handleAddLocationResponse(success:error:))
        }
        

    
    func handleAddLocationResponse( success: Bool, error: Error?){
            if success{
                UdacityClient.addStudentLocation(mapString: self.locationTextField.text, mediaURL: self.urlTextField.text, completion: handleAddLocationResponse(success:error:))
                self.performSegue(withIdentifier: "addToMap", sender: nil)
            } else {
                showAddLocationFailure(message: error?.localizedDescription ?? "")
            }
    }
    
    func showAddLocationFailure(message: String){
        DispatchQueue.main.async{
            let alertVC = UIAlertController(title: "Ugh Adding Location Failed", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.show(alertVC, sender: nil)
        }
    
    }
    
    

}
