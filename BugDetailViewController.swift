//
//  BugDetailViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/8/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//
//  Description: Detail view that is accessed by tapping a bug via the BugsTableViewController or AdvancedSearchViewController. Displays the details for a single bug in table form sorted by section as dictated by input data sheet.

import Foundation
import UIKit
import CoreData

// Delegate method to send data back from popover
protocol myPopoverDelegate: class {
    func sentPopoverData(option: String)
}

class BugDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, myPopoverDelegate {

    @IBOutlet var DetailTable: UITableView!
    @IBOutlet var detailTitle: UINavigationItem!
    
    var passedName:String = "Default Name"
    var passedSearch:String = "none"
    
    var section:[String] = []
    var items:[[String]] = []
    var imageURLs:[IndexPath:String] = [:]
    
    var popoverButton: UIBarButtonItem?
    
    
    override func viewWillAppear(_ animated: Bool) {
       
        // Set up Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        // Check if data needs to be reloaded (case of data update)
        if MyGlobalVariable.timesReloaded_DetailTable == 0 {
            
            // Get Detail table sections and items from CoreBugsData
            var sectionFormatted:[String] = []
            var itemsFormatted:[[String]] = []
            
            // Get details from CoreBugsData for specific name passed from BugsTableViewController
            let dataArray = BugsManager.sharedInstance.fetchBugDetails(forBugName: passedName)
            let obj = dataArray as [Dictionary<String, String>]
            for item in obj {
                for (key, value) in item { // Loop through bug detail data setting key = column name, value = column detail
                    sectionFormatted.append(key)
                    itemsFormatted.append((value as AnyObject).components(separatedBy: "; ")) // Break out detail by semicolons, as formatted in CSV
                }
            }
        
            section = sectionFormatted
            items = itemsFormatted
            
            DetailTable.reloadData()

            MyGlobalVariable.timesReloaded_BugsTable = 1 // make sure data isn't reloaded again
        }
        
    }

    // Set up tables
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = MyGlobalVariable.themeMainColor
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section [section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath as IndexPath)
        
        var cellText = self.items[indexPath.section][indexPath.row]
        var cellImage = "none"
        
        // Check for image and format as necessary
        if let dotRange = cellText.range(of: "url:") {
            cellImage = cellText
            
            cellText.removeSubrange(dotRange.lowerBound..<cellText.endIndex)
            let startIndex = cellText.index(cellText.startIndex, offsetBy: cellText.characters.count)
            cellImage = cellImage.substring(from: startIndex)
            cellImage = cellImage.replacingOccurrences(of: "url:", with: "")
            
            imageURLs[indexPath] = cellImage
            
            
            // Add right image to indicate more info
            //cell.accessoryType = UITableViewCellAccessoryType.detailButton
            
            cell.isUserInteractionEnabled = true
        } else{
            cell.isUserInteractionEnabled = false
        }
        
        cell.textLabel?.isEnabled = true
        
        // Highlight searched text
        let attribute = NSMutableAttributedString.init(string: cellText)
        let splitSearchArray = passedSearch.components(separatedBy: " ")
        
        for searchTerm in splitSearchArray {
            let range = (cellText.lowercased() as NSString).range(of: searchTerm.lowercased())
            attribute.addAttribute(NSBackgroundColorAttributeName, value: UIColor.yellow , range: range)
        }
        
        
        // Set attributed text on a UILabel
        cell.textLabel?.attributedText = attribute
        
        // Allow line breaks if the text is too long
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        //cell.textLabel?.text = self.items[indexPath.section][indexPath.row]
        return cell
    }
    
    // Use willDisplayCell to show cell accessory
    // Note: Using in cellForRowAtIndexPath causes cells that should NOT have an accessory to sometimes have one while scrolling
    func tableView(_ willDisplayforRowAttableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (cell.isUserInteractionEnabled) {
            // Add right image to indicate more info
            cell.accessoryType = UITableViewCellAccessoryType.detailButton
        } else{
            // For some reason, this is REQUIRED to make sure there are no visual glitches
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    // Receive data from popover to determine which option was selected
    var popoverSegueAction = "none"
    func sentPopoverData(option: String) {
        
        // Select correct action for chosen popover
        popoverSegueAction = option
        if option == "report" {
            self.performSegue(withIdentifier: "imageSegue", sender: self)
        }
        
    }
    
    func initiatePopover(_ sender: AnyObject) {
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverController") as? PopoverController
        
        
        // set the presentation style
        popController?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // Set popover data (format as array: userfriendly,action)
        PopoverController.popoverOptions = ["Suggest Change,report"]
        
        // set up the popover presentation controller
        popController?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController?.popoverPresentationController?.delegate = self
        popController?.delegate = self
        popController?.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        // present the popover
        self.present(popController!, animated: false, completion: nil)
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    
    // Send data to detail view when user taps a cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue")
        if segue.identifier == "imageSegue" {
            // Segue to show web resource for bug
            if let indexPath = DetailTable.indexPathForSelectedRow {

                
                if let toViewController = segue.destination as? ImageViewController {
                    toViewController.passedImage = imageURLs[indexPath]!
                    toViewController.passedTitle = "Web Resource"
                }
                
            } else if popoverSegueAction == "report"{
                // Segue to show google form to report data errors
                if let toViewController = segue.destination as? ImageViewController {
                    toViewController.passedImage = "https://docs.google.com/forms/d/e/1FAIpQLSfLFB4wQq5mbuwBuqTTjFheWsKVLL4enUjFgY6iz5uvHmwVLQ/viewform?usp=pp_url&entry.286988055=\(passedName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))&entry.1744268545"
                    toViewController.passedTitle = "Report Data"
                }
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.detailTitle.title = passedName
        
        // Set up overall background
        self.view.backgroundColor = MyGlobalVariable.themeBackgroundColor
        DetailTable.backgroundColor = MyGlobalVariable.themeBackgroundColor
        
        
        // Allow table cell to get bigger to fit wrapped content
        DetailTable.estimatedRowHeight = 44
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Add button to top right to report errors
        //popoverButton = UIBarButtonItem(image: UIImage(named: "flagIcon"),  style: .plain, target: self, action: #selector(BugDetailViewController.reportMistake))
        popoverButton = UIBarButtonItem(title: "Options", style: UIBarButtonItemStyle.plain, target: self, action: #selector(initiatePopover))
        
        navigationItem.rightBarButtonItems = [popoverButton!]

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
