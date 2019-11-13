//
//  WebViewController.swift
//  OnMap
//
//  Created by William Lewis on 11/11/19.
//  Copyright © 2019 William Lewis. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var location: Location!
    var locationTitle = ""
    var urlString = " "
    var altWebsites = ["Google": TableViewController.Google.google, "Linkedin": TableViewController.Google.linkedin]
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(openTapped))
        
        let url = URL(string: urlString)! //just stores the location of files after creating URL out of string
        webView.load(URLRequest(url: url)) //ios URL type has to go to URLRequest in order to load
        webView.allowsBackForwardNavigationGestures = true //allow user to go drag back or forward
        
        self.navigationController?.isToolbarHidden = true
        
        print(url)
    }
    //decide whether to allow navigation
    //you are given the decisionHandler as a closure and expected to do someting with it
    //you can show some user interface to the user "Do you really want to load this page?"
    /*
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for (_, webUrl) in altWebsites {
                if host.contains("\(String(describing: webUrl))") {
                       decisionHandler(.allow)
                       return
                   }
               }
           }
           decisionHandler(.cancel)
    }
    */
    @objc func openTapped() {
        let ac = UIAlertController(title: "More info…", message: nil, preferredStyle: .actionSheet)
        for (website, _) in altWebsites {
            ac.addAction(UIAlertAction(title: "\(String(describing: website))", style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        //popoverPresentationController?.barButtonItem property is used only on iPad, and tells iOS where it should make the action sheet be anchored.
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    func openPage(action: UIAlertAction) {
        for (website, webUrl) in altWebsites {
            if action.title == website {
                let url = URL(string: "\(String(describing: webUrl))")
                webView.load(URLRequest(url: url!))
            }
            
        }
//        let url = URL(string: "https://" + action.title!)! //double because we know actions have a title and because we know url will exist
        
    }
    
    

    

}
