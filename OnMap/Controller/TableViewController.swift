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
    var firstName = ""
    var lastName = ""
    lazy var name = firstName + " " + lastName
  
    //lazy var name: String = firstName + "+" + lastName  //has to be lazy bc its a computed variable that depends on another instance property
    
    enum Google {
        static let base = "https://www.google.com/search?q="
        static let space = "+"
        
        case google(String)
        case linkedin(String)
        
        var stringValue: String {
            switch self {
            case .google(let name):
                return Google.base + "\(name)"
            case .linkedin(let name):
                return Google.base + "\(name)" + Google.space + "linkedin"
            }
        }
        var url: URL{
            return URL(string: stringValue) ?? URL(string: "https://udacity.com")!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.navigationItem.title = "Approved Links or Google"
            //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(openTapped))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped))
            //self.tableView?.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UdacityClient.getStudentLocations() { locations, error in
                LocationModel.locations = locations
       // print(locations)
        }
        DispatchQueue.main.async{
            self.tableView?.reloadData()
            
        }
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToWeb" {
            let detailVC = segue.destination as! WebViewController
            detailVC.location = LocationModel.locations[selectedIndex]
        }
    }
    
    @objc func addTapped(){
        
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
        
        let first = (location.firstName ?? "")
        let last = (location.lastName ?? "")
    
        
        firstName = (location.firstName ?? "")
        lastName = (location.lastName ?? "")
        //let combined = firstName + "+" + lastName
        //name = combined
        cell.textLabel?.text = firstName + " " + lastName
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
        detailController.urlString = setURL(urlString: location.mediaURL, first: firstName, last: lastName)
        print("urlString set to \(detailController.urlString)")
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
    //Verify the url and if its no good try verifying a name and using a google search of name...if name no good...then use default
    func setURL(urlString: String?, first: String?, last: String?) -> String {
        //let location = LocationModel.locations[(indexPath as NSIndexPath).row]
        let combined = firstName + "+" + lastName
        name = combined
        
        if verifyUrl(urlString: urlString) {
            return urlString!
        } else if verifyName(first: firstName, last: lastName) {
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

    
    
}
