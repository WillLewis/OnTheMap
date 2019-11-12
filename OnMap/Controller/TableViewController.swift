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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = UdacityClient.getStudentLocations() { locations, error in
                LocationModel.locations = locations
        }
            
        DispatchQueue.main.async{
            self.tableView?.reloadData()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToWeb" {
            let detailVC = segue.destination as! WebViewController
            detailVC.location = LocationModel.locations[selectedIndex]
        }
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
        
        cell.textLabel?.text = location.firstName + " " + location.lastName
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text =  "\(location.mediaURL)"

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        //detailController.locationTitle = self.LocationModel.locations[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
