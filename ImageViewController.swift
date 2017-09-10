//
//  ImageViewController.swift
//  IDReference
//
//  Created by Cole Denkensohn on 1/15/17.
//  Copyright © 2017 Cole Denkensohn. All rights reserved.
//
//  Description: Displays web content from within the app with option to open content in Safari. Sources are (1) individual bug web resources, (2) reporting bug errors google form, and (3) general feedback google form.

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate, UIWebViewDelegate {
    
    @IBOutlet var myWebView: UIWebView!
    

    @IBOutlet var pageTitle: UINavigationItem!
    var passedImage:String = "Default Name"
    var passedTitle:String = "Web Resource"
    
    @IBAction func actionButton(_ sender: Any) {
        // Open link in Safari rather than within app for full functionality
        let url = URL(string: passedImage)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        // Close view
        self.dismiss(animated: true, completion: nil)
    }
    
    //Create Activity Indicator
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        myActivityIndicator.startAnimating()
        print("Web view started loading")
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myActivityIndicator.stopAnimating()
        print("Web view finished loading")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Something went wrong")
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        if currentReachabilityStatus == .notReachable { // If user has no internet
            // Notify user of updated data
            let alert = UIAlertController(title: "Offline", message: "Network connection required to view online resources.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if currentReachabilityStatus != .notReachable { // Ensure user has internet
            myWebView.loadRequest(URLRequest(url: URL(string: passedImage)!))
            myWebView.delegate=self
        }
        
        // Prepare Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = MyGlobalVariable.themeMainColor
        self.navigationController?.navigationBar.barTintColor = MyGlobalVariable.themeMainColor
        //self.navigationController?.navigationBar.tintColor = MyGlobalVariable.themeLightBlue
        pageTitle.title = passedTitle
        
        // Set up activity indicator
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
