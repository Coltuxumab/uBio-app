//
//  SecondViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/7/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//
//  Description: Checks web for new version of data (if internet is available) by comparing stored version number to web version number and enables update button if the two are different.

import UIKit
import CoreData

class UpdateDataViewController: UIViewController {

    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var webVersionLabel: UILabel!
    @IBOutlet var webVersionNotes: UITextView!
    
    @IBOutlet var updateBugsButton: UIButton!
    @IBAction func updateBugsButton(_ sender: UIButton) {
        self.versionLabel.text = "x.x.x" // Set temporary version label
        
        updateBugsButton.isEnabled = false // Disable the update button
        self.versionLabel.text = "Updating"
        
        // Count number of records
        //print("Count: \(BugsManager.sharedInstance.getArrayItemsAtHeader(header: "count", file: "https://docs.google.com/spreadsheets/d/1ejV10xF41Jg2NOaV4LZEta-g57JUKmrVMCsNBJrB4WI/pub?gid=1968227284&single=true&output=csv")[0])")
        
        // Download new data.csv from web, read csv async, and generate needed vars
        BugsManager.sharedInstance.downloadNewData(webURL: "https://docs.google.com/spreadsheets/d/1ejV10xF41Jg2NOaV4LZEta-g57JUKmrVMCsNBJrB4WI/pub?gid=0&single=true&output=csv")
        
        
        // Clean up version numbers
        BugsManager.sharedInstance.deleteAllSettings() // Delete current CoreData version
        BugsManager.sharedInstance.setVersionNumber(newVersionNumber: self.webVersionLabel.text!) // Set CoreData version to web version
        self.versionLabel.text = self.webVersionLabel.text // Set versions the same
        
        // Remove tab badge
        tabBarController?.tabBar.items?[2].badgeValue = nil
        
        // Allow other pages grabbing the data to refresh when the load
        MyGlobalVariable.timesReloaded_AdvancedSearch = 0
        MyGlobalVariable.timesReloaded_BugsTable = 0
        MyGlobalVariable.timesReloaded_DetailTable = 0
        
        // Set global update status variable to false
        MyGlobalVariable.updateAvailable = false
        
        // Notify user of updated data
        let alert = UIAlertController(title: "Data Updated", message: "You now have the most current data available for use offline.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = MyGlobalVariable.themeMainColor
        self.navigationController?.navigationBar.barTintColor = MyGlobalVariable.themeMainColor
        self.title = "Update Data"
        
        // Get app data version number from CoreData
        self.versionLabel.text = BugsManager.sharedInstance.getVersionNumber()
        
        if currentReachabilityStatus != .notReachable { // Ensure user has internet
            // Get web version number from CSV
            //self.webVersionLabel.text = BugsManager.sharedInstance.getArrayItemsAtHeader(header: "version", file: "https://docs.google.com/spreadsheets/d/1xE_39C3oGA4D3IPGPuSU0ajuBZ1l1nLAzXX2lKG-Ie0/pub?gid=639913403&single=true&output=csv")[0]
            let webVersionLabelString = BugsManager.sharedInstance.getArrayItemsAtHeader(header: "version", file: "https://docs.google.com/spreadsheets/d/1ejV10xF41Jg2NOaV4LZEta-g57JUKmrVMCsNBJrB4WI/pub?gid=1968227284&single=true&output=csv")[0]
            self.webVersionLabel.text = webVersionLabelString
            
            // Get notes for update
            let webVersionNotesArray = BugsManager.sharedInstance.getArrayItemsAtHeader(header: "notes", file: "https://docs.google.com/spreadsheets/d/1ejV10xF41Jg2NOaV4LZEta-g57JUKmrVMCsNBJrB4WI/pub?gid=1968227284&single=true&output=csv")
            
            // Pull out each individual note in array
            var webVersionNotesString = "New in version \(webVersionLabelString):\n\n"
            for note in webVersionNotesArray {
                // Add note to string
                webVersionNotesString += "- \(note)\n"
            }
            // Send string to storyboard
            self.webVersionNotes.text = webVersionNotesString
            
            
            if self.versionLabel.text == self.webVersionLabel.text {
                // App version is the same as web version
            } else{
                // App version is different from web version (allow update by enabling update button)
                updateBugsButton.isEnabled = true
                
                // Set update available globally
                MyGlobalVariable.updateAvailable = true
            }
        } else { // Do not allow update if internet is unavailable
            self.webVersionLabel.text = "Offline"
            // Notify user of no internet
            let alert = UIAlertController(title: "No Internet", message: "You currently do not have internet. If you are on WiFi, try opening Safari to see if you need to log in.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

