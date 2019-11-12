//
//  LogViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/11/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTap(_ sender: Any) {
        setLogginIn(true)
        UdacityClient.createSession(completion: handleSessionResponse(success:error:))

    }
    
    func handleSessionResponse( success: Bool, error: Error?){
        setLogginIn(false)
        if success{
            performSegue(withIdentifier: "completeLogin", sender: nil)
        } else {
            showLoginFailure(message: error?.localizedDescription ?? "")
        }
    }
    
    func showLoginFailure(message: String){
        let alertVC = UIAlertController(title: "UhOh Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    
    }
    
    func setLogginIn (_ loggingIn: Bool) {
        if loggingIn {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        emailTextField.isEnabled = !loggingIn
        passwordTextField.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }
    

}
