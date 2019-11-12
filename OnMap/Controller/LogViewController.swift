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
        UdacityClient.createSession(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleSessionResponse(success:error:))
    }
    
    func handleSessionResponse( success: Bool, error: Error?){
        setLogginIn(false)
       
        DispatchQueue.main.async {
            if success{
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            } else {
                self.showLoginFailure(message: error?.localizedDescription ?? "")
            }
        }
    }
    
    func showLoginFailure(message: String){
        let alertVC = UIAlertController(title: "UhOh Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    
    }
    
    func setLogginIn (_ loggingIn: Bool) {
        DispatchQueue.main.async {
            if loggingIn {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
            self.emailTextField.isEnabled = !loggingIn
            self.passwordTextField.isEnabled = !loggingIn
            self.loginButton.isEnabled = !loggingIn
        }
        
    }
    

}
