//
//  FeedbackViewController.swift
//  IDReference
//
//  Created by Cole Denkensohn on 1/22/17.
//  Copyright © 2017 Cole Denkensohn. All rights reserved.
//
//  Description: Static feedback page with link to Google form to submit feedback.

import Foundation
import UIKit
import CoreData

class FeedbackViewController: UIViewController {

    
    
    @IBOutlet var submitFeedbackButton: UIButton!
    // Send user to ImageViewController and load the general feedback google sheet
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue")
        if segue.identifier == "submitFeedbackSegue" {

            if let toViewController = segue.destination as? ImageViewController {
                toViewController.passedImage = "https://docs.google.com/forms/d/e/1FAIpQLSez3JhQfoQL4UxWkYSow82kJ-TENxTGh1MxFLcFAOj-g9VUxA/viewform?usp=sf_link"
                toViewController.passedTitle = "Submit Feedback"
            }
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if currentReachabilityStatus == .notReachable { // If user has no internet
            submitFeedbackButton.isEnabled = false
            // Notify user of updated data
            let alert = UIAlertController(title: "Offline", message: "Network connection required to submit feedback.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else{
            submitFeedbackButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set up Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = MyGlobalVariable.themeMainColor
        self.navigationController?.navigationBar.barTintColor = MyGlobalVariable.themeMainColor
        self.title = "Feedback"
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
