//
//  SecondViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/7/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import Foundation

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    var first = ""
    var last = ""
    lazy var name = first + " " + last
  
    //lazy var name: String = firstName + "+" + lastName  //has to be lazy bc its a computed variable that depends on another instance property
    
    enum Google {
        static let base = "https://www.google.com/search?q="
        static let space = "+"
        
        case google(String)
        case linkedin(String)
        
        var stringsValue: String {
            switch self {
            case .google(let name):
                return Google.base + "\(name)"
            case .linkedin(let name):
                return Google.base + "\(name)" + Google.space + "linkedin"
            }
        }
        var url: URL{
            return URL(string: stringsValue) ?? URL(string: "https://udacity.com")!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UdacityClient.getStudentLocations() {(data, error) in
            guard data != nil else {
            return
            }
            DispatchQueue.main.async {
                self.navigationItem.title = "Approved Links or Google"
                //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(openTapped))
                let add  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
                let reload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reLoad))
                self.navigationItem.rightBarButtonItems = [add, reload]
                
                let exit = UIBarButtonItem(title: "LOGOUT" , style: .plain, target: self, action: #selector(self.exitOnMap))
                self.navigationItem.leftBarButtonItem = exit
                
                self.tableView?.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.reloadData()
        /*
        UdacityClient.getStudentLocations() { locations, error in
                LocationModel.locations = locations
       // print(locations)
        }
        DispatchQueue.main.async{
            self.tableView?.reloadData()
        }
     */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToWeb" {
            let detailVC = segue.destination as! WebViewController
            detailVC.location = LocationModel.locations[selectedIndex]
        }
    }
    @objc func exitOnMap (){
           UdacityClient.deleteSession(completion: handleLogOutResponse(success:error:))
           
       }
       
       func handleLogOutResponse (success: Bool, error: Error?) {
           if success {
              let detailVC = storyboard!.instantiateViewController(identifier: "Login") as! LogViewController
               //detailVC.title = "Login"
               navigationController?.pushViewController(detailVC, animated: true)
               
           } else {
               showLogoutFailure(message: error?.localizedDescription ?? "")
           }
       }
    
    @objc func addTapped(){
        let detailVC = storyboard!.instantiateViewController(identifier: "AddLocation") as! AddLocationViewController
        detailVC.title = "Add Location"
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    @objc func reLoad(){
        self.tableView?.reloadData()
    }
}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationModel.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        
        let location = LocationModel.locations[indexPath.row]
        
        first = (location.firstName ?? "")
        last = (location.lastName ?? "")
       
        cell.textLabel?.text = first + " " + last
        cell.imageView?.image = UIImage(named: "icon_pin")
        
       if let detailTextLabel = cell.detailTextLabel {
        detailTextLabel.text =  setURL(urlString: location.mediaURL, first: first, last: last)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = LocationModel.locations[indexPath.row]
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        detailController.locationTitle = "\(LocationModel.locations[(indexPath as NSIndexPath).row])"
        detailController.urlString = setURL(urlString: location.mediaURL, first: first, last: last)
        print("urlString set to \(detailController.urlString)")
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    /* if the url can be opened use that as the url
     ...if its no good try verifying the name, and if ok, use a google search of name
     ...if the name is no good...then use linkedin as the default url*/
    func setURL(urlString: String?, first: String?, last: String?) -> String {
        let name = (first ?? "") + "+" + (last ?? "")
        
        
        if verifyUrl(urlString: urlString) {
            return urlString!
        } else if verifyName(first: self.first, last: self.last) {
            return (String(describing: Google.google(name).url))
        } else {
            return "https://www.linkedin.com"
        }
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func verifyName(first: String?, last: String?) -> Bool {
        let letters = CharacterSet.letters
        if first?.rangeOfCharacter(from: letters) != nil || last?.rangeOfCharacter(from: letters) != nil{
            return true
        } else{
            return false
        }
    }
    
    func showLogoutFailure(message: String){
        DispatchQueue.main.async{
            let alertVC = UIAlertController(title: "LogOut Failed", message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.show(alertVC, sender: nil)
        }
    
    }
    
        
}
