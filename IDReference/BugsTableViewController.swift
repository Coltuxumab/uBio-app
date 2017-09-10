//
//  bugsTableViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/7/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//
//  Description: ViewController for the main page (home tab at the bottom). Displays bugs sorted by name and allows for search by name only.

import Foundation
import UIKit
import CoreData

class BugsTableViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate {
    
    
    @IBOutlet weak var BugsTable: UITableView!

    
    var bugsList = BugsManager.sharedInstance.bugs // Array of bugs from BugsManager
    var bugsSearchResults:[String] = [] // Array of bugs from search results
    var shouldShowSearchResults = false // Search was performed
    let searchController = UISearchController(searchResultsController: nil)
    var tableHeader:Int = 0
    var refreshControl: UIRefreshControl!
    
    // BEGIN: Table
    
    // Table View Data Source Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shouldShowSearchResults { // Search view
            return bugsSearchResults.count
        } else if tableHeader == 99999999 { // Case of no results on search
            return 0
        }
        return bugsList.count // Get number of bugs from BugsManager
        
    }
    
    // Provide a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = BugsTable.dequeueReusableCell(withIdentifier: "BugsTableCell")!
        
        var bugName : String!
        if shouldShowSearchResults { // Search view
            bugName = bugsSearchResults[indexPath.row]
        } else { // No search was made
            bugName = bugsList[indexPath.row]
        }
        
        // Begin shell (attributed string) for final bugName
        let finalAttributedString = NSMutableAttributedString()
        
        // Add bug name in bigger font
        finalAttributedString.append(NSMutableAttributedString.init(string: bugName, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!]))
        
        // Check for subtext
        var bugSubText = "null" // PLACEHOLDER
        
        // Allow text wrap if bug name is too long
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        // Get bug type
        let bugDetails = BugsManager.sharedInstance.fetchBugDetails(forBugName: bugName)
        var bugType = "unknown"
        for item in bugDetails {
            for (key,value) in item{
                if key == "Type"{
                    bugType = value
                }
            }
        }
        
        // Choose which image to add
        if bugType == "Bacteria" {
            bugType = "Table Icon - BacteriaUnknown"
            var bacteriaGramMorph = "unknown"
            
            // Add bacteria subtext
            for item in bugDetails {
                for (key,value) in item{
                    if key == "Gram Stain" && !value.isEmpty{
                        bugSubText = value.lowercased()
                        bacteriaGramMorph = value.lowercased()
                    }
                    if key == "Morphology" && !value.isEmpty{
                        if bugSubText == "null" {
                            bugSubText = " \(value.lowercased())"
                        } else{
                            bugSubText += " \(value.lowercased())"
                            bacteriaGramMorph = "\(value.lowercased()) \(bacteriaGramMorph)"
                        }
                    }
                    
                    // If morphology and gram stain are present, we can use the correct icon
                    if bacteriaGramMorph == "rod gram positive"{
                        bugType = "Table Icon - BacteriaRodGP"
                    } else if bacteriaGramMorph == "rod gram negative"{
                        bugType = "Table Icon - BacteriaRodGN"
                    } else if bacteriaGramMorph == "cocci gram positive"{
                        bugType = "Table Icon - BacteriaCocciGP"
                    } else if bacteriaGramMorph == "cocci gram negative"{
                        bugType = "Table Icon - BacteriaCocciGN"
                    } else if bacteriaGramMorph == "cocci in pairs gram positive" || bacteriaGramMorph == "diplococcus gram positive"{
                        bugType = "Table Icon - BacteriaCocciPairsGP"
                    } else if bacteriaGramMorph == "cocci in pairs gram negative" || bacteriaGramMorph == "diplococcus gram negative"{
                        bugType = "Table Icon - BacteriaCocciPairsGN"
                    } else if bacteriaGramMorph == "cocci in clusters gram positive"{
                        bugType = "Table Icon - BacteriaCocciClustersGP"
                    } else if bacteriaGramMorph == "cocci in clusters gram negative"{
                        bugType = "Table Icon - BacteriaCocciClustersGN"
                    }
                }
            }
        } else if bugType == "Virus"{
            bugType = "Table Icon - Virus"
            
            // Add subtext
            for item in bugDetails {
                for (key,value) in item{
                    if key == "Key Points" && !value.isEmpty{
                        // If the Key Point contains a URL, remove it before displaying the text
                        if let dotRange = value.range(of: "url:") {
                            var valueSansURL = value
                            valueSansURL.removeSubrange(dotRange.lowerBound..<valueSansURL.endIndex)
                            bugSubText = valueSansURL.lowercased()
                        } else{
                            bugSubText = value.lowercased()
                        }
                        
                    }
                }
            }
            
            
        } else if bugType == "Fungus"{
            bugType = "Table Icon - Fungi"
            
            // Add subtext
            for item in bugDetails {
                for (key,value) in item{
                    if key == "Key Points" && !value.isEmpty{
                        // If the Key Point contains a URL, remove it before displaying the text
                        if let dotRange = value.range(of: "url:") {
                            var valueSansURL = value
                            valueSansURL.removeSubrange(dotRange.lowerBound..<valueSansURL.endIndex)
                            bugSubText = valueSansURL.lowercased()
                        } else{
                            bugSubText = value.lowercased()
                        }
                        
                    }
                }
            }
        } else{
            bugType = "Table Icon - Parasite"
            
            // Add subtext
            for item in bugDetails {
                for (key,value) in item{
                    if key == "Key Points" && !value.isEmpty{
                        // If the Key Point contains a URL, remove it before displaying the text
                        if let dotRange = value.range(of: "url:") {
                            var valueSansURL = value
                            valueSansURL.removeSubrange(dotRange.lowerBound..<valueSansURL.endIndex)
                            bugSubText = valueSansURL.lowercased()
                        } else{
                            bugSubText = value.lowercased()
                        }
                        
                    }
                }
            }
        }
        
        // Append subtext if it exists
        if(bugSubText != "null"){
        
            // Format subtext
            //let range = (bugSubText.lowercased() as NSString).range(of: bugSubText.lowercased())
            let bugSubTextAttributed = NSMutableAttributedString.init(string: bugSubText, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!, NSForegroundColorAttributeName: MyGlobalVariable.themeLightGrey])
        
            finalAttributedString.append(NSMutableAttributedString.init(string: "\n"))
            finalAttributedString.append(bugSubTextAttributed)
            
        }
        
        // Send attributed text to UILabel
        cell.textLabel?.attributedText = finalAttributedString
        
        // Add left image based on type
        let image : UIImage = UIImage(named: bugType)!
        cell.imageView?.image = image
        
        return cell
        
    }
    
    // Set up table header (shows status of search results)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if bugsList.count == 0{
            return "Loading initial data..."
        }
        
        if shouldShowSearchResults{
            return "Your search found \(tableHeader) results"
        } else if tableHeader == 99999999{
            return "Nothing found"
        } else{
            return "Showing all results"
        }
        
    }
    
    // Set up table header style
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = MyGlobalVariable.themeMainColor
    }
    
    
    // END: Table

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MyGlobalVariable.timesReloaded_BugsTable == 0 {
            
            // Reset table when coming from another view (view may have been a data update)
            BugsManager.sharedInstance.bugs = [String]()
            BugsManager.sharedInstance.fetchBugs()
            bugsList = BugsManager.sharedInstance.bugs
            
            MyGlobalVariable.timesReloaded_BugsTable = 1 // make sure data isn't reloaded again
        }
        
        // Check for previous search text (view may have been a detail view)
        if searchController.searchBar.text != ""{
            // Filter results based on search text
            filterContent(searchText: searchController.searchBar.text!)
        }
        
        BugsTable.reloadData()

    }
    override func viewDidAppear(_ animated: Bool) {
        
        // Check for previous search text (view may have been a detail view)
        if searchController.searchBar.text != "" && self.BugsTable.contentOffset.y == 0{
            // Set search bar as active to allow user to cancel search UNLESS the user has scrolled down
            DispatchQueue.main.async {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
        
    }
    
    // Send data to detail view when someone taps a cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set back button
        let backItem = UIBarButtonItem()
        backItem.title = "All"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        if segue.identifier == "bugDetailSegue" {

            if let indexPath = BugsTable.indexPathForSelectedRow {
                
                let DestViewController : BugDetailViewController = segue.destination as! BugDetailViewController
                
                if shouldShowSearchResults && searchController.searchBar.text != "" {
                    DestViewController.passedName = bugsSearchResults[indexPath.row]
                } else {
                    DestViewController.passedName = bugsList[indexPath.row]
                }
                
            }
        
        }

    }
    
    
    // BEGIN: Handle Search
    
    func updateSearchResults(for searchController: UISearchController){

        filterContent(searchText: self.searchController.searchBar.text!)
        
        if !searchController.isActive {
            // Nothing to search for, reset table
            tableHeader = 0
            shouldShowSearchResults = false
            BugsTable.reloadData()
        }
 
    }
    override func viewWillDisappear(_ animated: Bool) { // remove searchbar after segue
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func filterContent(searchText:String) {
        
        bugsSearchResults = bugsList.filter { bugs in
            let username = bugs
            return(username.lowercased().contains(searchText.lowercased()))
        }
        if(bugsSearchResults.count == 0){
            shouldShowSearchResults = false
            tableHeader = 99999999 // Case of no results
        } else {
            shouldShowSearchResults = true
            tableHeader = bugsSearchResults.count
        }
        BugsTable.reloadData()
    }
    
    // END: Handle Search
    
    // Check for data updates
    func checkDataUpdates(){
        
        if currentReachabilityStatus != .notReachable { // Ensure user has internet
            let webDataVersion = BugsManager.sharedInstance.getArrayItemsAtHeader(header: "version", file: "https://docs.google.com/spreadsheets/d/1ejV10xF41Jg2NOaV4LZEta-g57JUKmrVMCsNBJrB4WI/pub?gid=1968227284&single=true&output=csv")[0]
            let coreDataVersion = BugsManager.sharedInstance.getVersionNumber()
            
            // Get web version number from CSV
            if webDataVersion != coreDataVersion {
                // Set tab badge
                tabBarController?.tabBar.items?[2].badgeValue = "1"
                MyGlobalVariable.updateAvailable = true
            } else{
                // Set tab badge
                tabBarController?.tabBar.items?[2].badgeValue = nil
                MyGlobalVariable.updateAvailable = false
            }
            
        } else{
            // Notify user of no internet
            let alert = UIAlertController(title: "No Internet", message: "You currently do not have internet. If you are on WiFi, try opening Safari to see if you need to log in.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        refreshControl.endRefreshing()
    }
    
    // View LIFECYCLE BELOW
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up data
        if bugsList.count == 0 {
            // There is no data to show yet (it is being called async from the included csv)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                
                // Checking for data again
                if self.bugsList.count == 0{
                    
                    // Still, there is no data
                    BugsManager.sharedInstance.fetchBugs()
                    self.bugsList = BugsManager.sharedInstance.bugs
                    self.BugsTable.reloadData()
                
                } else{
                    // Now there is data!
                }
            })
            
        }
        
        // Allow table cell to get bigger to fit wrapped content
        BugsTable.estimatedRowHeight = 44
        
        // Set up overall background
        self.view.backgroundColor = MyGlobalVariable.themeBackgroundColor
        BugsTable.backgroundColor = MyGlobalVariable.themeBackgroundColor
        
        // Set background color of bounce area (behind table)
        let bgView = UIView()
        bgView.backgroundColor = MyGlobalVariable.themeBackgroundColor
        self.BugsTable.backgroundView = bgView
        
        // Set up navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = MyGlobalVariable.themeMainColor
        self.navigationController?.navigationBar.barTintColor = MyGlobalVariable.themeMainColor
        //self.navigationController?.navigationBar.tintColor = MyGlobalVariable.themeLightBlue
        //self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        navigationItem.title = "Search by Name"
        
        // Set up table view pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Check for new data")
        refreshControl.addTarget(self, action: #selector(self.checkDataUpdates), for: UIControlEvents.valueChanged)
        BugsTable.addSubview(refreshControl)
        
        // Set up search bar
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        BugsTable.tableHeaderView = searchController.searchBar
        searchController.searchBar.barTintColor = MyGlobalVariable.themeMainColor
        
        // Cancel button
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
        
        // Check for updates to data if user has internet and display badge icon if needed
        //checkDataUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

