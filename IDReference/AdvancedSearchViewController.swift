//
//  AdvancedSearchViewController.swift
//  IDReference
//
//  Created by Cole Denkensohn on 1/13/17.
//  Copyright © 2017 Cole Denkensohn. All rights reserved.
//
//  Description: Top section displays cells containing data headers for selection. Bottom section is search table similar to the main BugsTable but with the ability to search by the category(s) selected from the top section.

import UIKit

class AdvancedSearchViewController: UIViewController, UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var ResultsTable: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    
    var BugsArray = BugsManager.sharedInstance.bugs
    var formattedBugsArray:[[String:String]] = [] // The array that contains names with details (best for searching)
    var bugsSearchResults:[[String:String]] = [] // Array of bugs from search results
    var collectionHeaders = [String]() // List of headers from spreatsheet (to narrow search)
    var shouldShowSearchResults = false // Determines if search was used
    var selectedCollection = [IndexPath]()
    let searchController = UISearchController(searchResultsController: nil)
    var tableHeader:Int = 0
    
    // Build an array (formattedBugsArray) that contains all bug names and details for easy searching
    func prepareAdvancedSearch(){
        self.collectionHeaders.append("Name")
        for bug in BugsArray{ // List out names
            
            var tempArray:[String:String] = [:] // Prepare dictionary array
            
            let BugDetails = BugsManager.sharedInstance.fetchBugDetails(forBugName: bug) // Grab details for bug
            
            tempArray["name"] = bug // Set name for dictionary
            
            for detailsShell in BugDetails{
                
                for (key,value) in detailsShell{
                    
                    tempArray.updateValue(value, forKey: key) // Set all details for bug (name already set)
                    
                    // Collect all details headers for use in narrowing down search (collection)
                    if collectionHeaders.contains(key) {
                        //Nothing
                    } else{
                        collectionHeaders.append(key)
                    }
                }
            }
            formattedBugsArray.append(tempArray) // Add new dictionary array (new bug name with details)
        }
        
        
    }
    
    // BEGIN: Collection
    let reuseIdentifier = "collectioncell"
    
    // UICollectionViewDataSource protocol
    let cellUnselectedColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
    let cellSelectedColor = MyGlobalVariable.themeLightBlue
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionHeaders.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! AdvancedSearchCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.myLabel.text = self.collectionHeaders[indexPath.item]
        
        // Set initial cell colors
        if selectedCollection.contains(indexPath){
            // Set colors
            cell.backgroundColor = cellSelectedColor
        } else{
            // Set colors
            cell.backgroundColor = cellUnselectedColor
        }
        
        cell.contentView.alpha = 0
        
        // Set border and radius
        //cell.layer.borderWidth = 1
        //cell.layer.cornerRadius = 8
        
        // Set drop shadow
        /*cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath*/
        
        return cell
    }
    
    // Actions when user touches cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if selectedCollection.contains(indexPath){
            //print(indexPath)
            // Cell is selected, so unselect it
            selectedCollection.remove(at: selectedCollection.index(of: indexPath)!)
            
            // Set colors
            cell?.backgroundColor = cellUnselectedColor
        } else{
            // Cell is not selected, so select it
            selectedCollection.append(indexPath)
            
            // Set colors
            cell?.backgroundColor = cellSelectedColor
        }
        
        // Check if search text is entered (user wants to search by different header)
        if !self.searchController.searchBar.text!.isEmpty{
            // Update results with new header
            filterContent(searchText: self.searchController.searchBar.text!)
        }
        //print("Updated selection: \(selectedCollection)")
        
    }
    
    var numberCollectionsFadedIn:Int = 0
    // Make sure that non-active cells off screen get the correct background when brough on
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell:UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if selectedCollection.contains(indexPath){
            // Set colors
            cell.backgroundColor = cellSelectedColor
            print("Cell coming on: \(String(describing: cell.backgroundColor))")
        } else{
            // Set colors
            cell.backgroundColor = cellUnselectedColor
        }
        
        // Fade in cells once they've loaded
        if numberCollectionsFadedIn > 8 && numberCollectionsFadedIn < 16 {
            //print("Fading: \(0.8+(0.1*Double(indexPath[1])))")
            UIView.animate(withDuration: 0.8, animations: { () -> Void in
                cell.contentView.alpha = 1.0
            })
            
        } else{
            cell.contentView.alpha = 1.0
        }
        numberCollectionsFadedIn += 1
    }
    
    // MARK: - UICollectionViewDelegate protocol
    

    // END: Collection
    
    // Function for button (top right) to select all or none of the categories
    var currentAllNoneSelection = "all"
    func selectAllNone(){
        //print("Before: \(selectedCollection)")
        
        // Loop through cells
        var currentCellNumber:Int = 0 // Counter
        selectedCollection.removeAll() // Empty the selected array
        // Select/deselect all cells
        while currentCellNumber < self.collectionHeaders.count {
            // Check if we should be selecting all or none
            if(currentAllNoneSelection == "all"){
                // Select all
                selectedCollection.append(IndexPath(row: currentCellNumber, section: 0))
                
            }
            currentCellNumber += 1
        }
        //print("After: \(selectedCollection)")
        
        // Set background color
        for cell in self.collectionView!.visibleCells as [UICollectionViewCell] {
            // Check if we should be selecting all or none
            if(currentAllNoneSelection == "all"){
                // Select all
                cell.backgroundColor = cellSelectedColor
                
            } else{
                // Select none
                cell.backgroundColor = cellUnselectedColor
                
            }
        }
        
        // Set UIBarButtonItem
        if(currentAllNoneSelection == "all"){
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "None", style: .plain, target: self, action: #selector(AdvancedSearchViewController.selectAllNone))]
            self.navigationItem.rightBarButtonItem?.tintColor = MyGlobalVariable.themeBlue
            currentAllNoneSelection = "none"
        } else{
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "All", style: .plain, target: self, action: #selector(AdvancedSearchViewController.selectAllNone))]
            self.navigationItem.rightBarButtonItem?.tintColor = MyGlobalVariable.themeBlue
            currentAllNoneSelection = "all"
        }
        
        // Reload table data
        filterContent(searchText: searchController.searchBar.text!)
    }
    
    // BEGIN: Search
    func updateSearchResults(for searchController: UISearchController){
        
        if !self.searchController.searchBar.text!.isEmpty{ // Make sure search bar is not empty
            filterContent(searchText: self.searchController.searchBar.text!)
        } else{
            // Nothing to search for, reset table
            shouldShowSearchResults = false
            ResultsTable.reloadData()
        }
        if !searchController.isActive {
            // Nothing to search for, reset table
            tableHeader = 0
            shouldShowSearchResults = false
            ResultsTable.reloadData()
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) { // remove searchbar after segue
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    func filterContent(searchText:String) {
        var filterByKeys = [String]()
        
        // Create list of headers that are selected
        for criteriaHeaders in selectedCollection{
            
            if collectionHeaders[criteriaHeaders.row] == "Name" { // Name is hard coded
                filterByKeys.append("name")
            } else{
                filterByKeys.append(collectionHeaders[criteriaHeaders.row])
            }
            
        }
        
        // Run filter
        
        //var searchStrengthArray:[[String:String]] = []
        var searchStrengthArray = [Int]()
        bugsSearchResults = formattedBugsArray.filter { bugs in

            var matchMade = false
            
            // Split search text into individual words to allow for searching to match in different categories
            let splitSearchArray = searchText.components(separatedBy: " ")
            //print("Number of words: \(splitSearchArray.count)")
            
            var numberMatched:Int = 0 // Used to rank search results
            
            // Unwrap headers that are selected for use in filtering
            for key in filterByKeys{
                
                if bugs[key] != nil{ // Only search if selected bug has the current key
                    let matchData = bugs[key]
                    
                    
                    for singleWord in splitSearchArray {
                        
                        if matchData!.lowercased().contains(singleWord.lowercased()) {
                            // If match is found, break
                            numberMatched += 1
                            matchMade = true
                            //break // (no need to find the match twice)
                        }
                        
                    }
                    // Set number matched as weight for filter
                    //print("Number matched for \(String(describing: bugs["name"])): \(numberMatched)")
                    
                }
                
                
            }
            //bugsSearchResults[0].updateValue(String(numberMatched), forKey: "searchStrength")
            //print(bugsSearchResults)
            if matchMade == true{
                searchStrengthArray.append(numberMatched)
            }
            
            return matchMade
        }
        //print("Bug search results: \(bugsSearchResults)")
        //print("Search strength array: \(searchStrengthArray)")
        
        // Append the search strength to the end of the results array
        var bugID = 0
        while bugID < bugsSearchResults.count {
            bugsSearchResults[bugID]["searchStrength"] = String(searchStrengthArray[bugID])
            bugID += 1
        }
        
        
        bugsSearchResults.sort{
            // Sort by strenth primarily and name secondarily if strength is equal
            if Int( ($0)["searchStrength"]! ) == Int( ($1)["searchStrength"]! ) {
                return ($0)["name"]! < ($1)["name"]!
            }
            return ( Int( ($0)["searchStrength"]! ) )! > ( Int( ($1)["searchStrength"]! ) )!
            
        }
        
        
        // Determine if any matches were made and display the appripriate content in the table
        if(bugsSearchResults.count == 0){
            shouldShowSearchResults = false
            tableHeader = 99999999 // Case of no results
            
        } else {
            shouldShowSearchResults = true
            tableHeader = bugsSearchResults.count
        }
        ResultsTable.reloadData()
        
    }
    
    // END: Search
    
    // BEGIN: Table
    
    // Table View Data Source Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if shouldShowSearchResults { // Search view
            return bugsSearchResults.count
        } else if tableHeader == 99999999 { // Case of no results on search
            return 0
        }
        return formattedBugsArray.count // Get number of bugs from BugsManager
        
    }
    
    func attributeTextWithSubtext (maintext:String, subtext:String) -> NSMutableAttributedString{
        
        let finalAttributedString = NSMutableAttributedString()
        
        // Format maintext
        finalAttributedString.append(NSMutableAttributedString.init(string: maintext, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 18.0)!]))
        
        // Format subtext
        let bugSubTextAttributed = NSMutableAttributedString.init(string: subtext, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!, NSForegroundColorAttributeName: MyGlobalVariable.themeLightGrey])
        
        // Combine maintext with subtext with line break
        finalAttributedString.append(NSMutableAttributedString.init(string: "\n"))
        finalAttributedString.append(bugSubTextAttributed)
        
        return finalAttributedString
    }
    
    // Provide a cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ResultsTable.dequeueReusableCell(withIdentifier: "tablecell")!
        
        // Allow line breaks if the text is too long
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        
        if shouldShowSearchResults { // Search view
            
            // Check if searchStrength is set and if so, sort by the strength
            if bugsSearchResults[indexPath.row]["searchStrength"] != nil {
                //bugName = "(\(bugsSearchResults[indexPath.row]["searchStrength"]!)) \(bugsSearchResults[indexPath.row]["name"]!)"
                cell.textLabel?.attributedText = attributeTextWithSubtext(
                        maintext: bugsSearchResults[indexPath.row]["name"]!,
                        subtext: "Matched \(bugsSearchResults[indexPath.row]["searchStrength"]!) search terms"
                )
                
            } else{
                cell.textLabel?.text = bugsSearchResults[indexPath.row]["name"]!
            }
            //print("Table item: \(bugsSearchResults[indexPath.row]["name"]!)")
        } else { // No search was made
            cell.textLabel?.text = formattedBugsArray[indexPath.row]["name"]
        }
        
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if shouldShowSearchResults{
            return "Your search found \(tableHeader) results"
        } else if tableHeader == 99999999 && selectedCollection.isEmpty{
            return "No category selected"
        } else if tableHeader == 99999999{
            return "Nothing found"
        } else if loadingCounter < 6 {
            return "Loading..."
        } else {
            return "Showing all results"
        }
        
    }
    // END: Table
    
    // Set up asynchronized background task for grabbing data
    let backgroundQueue = DispatchQueue(label: "com.app.queue",
    qos: .background,
    target: nil)
    var loadingCounter:Int = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if MyGlobalVariable.timesReloaded_AdvancedSearch == 0 {
            // Reset table when coming from another view (view may have been a data update)
            BugsManager.sharedInstance.bugs.removeAll()
            formattedBugsArray.removeAll()
            BugsManager.sharedInstance.fetchBugs()
            BugsArray = BugsManager.sharedInstance.bugs
            
            // Set up data off the main thread to avoid lag
            DispatchQueue.main.async {
                print("Dispatched to background queue")
                
                // Set up collection
                self.collectionHeaders.removeAll()
                
                // Grab data
                self.prepareAdvancedSearch()
                self.collectionView.reloadData()
                self.ResultsTable.reloadData()

            }
            
            // Show something for collection headers while async is loading
            while loadingCounter < 8 {

                self.collectionHeaders.append(" ")
                self.collectionView.reloadData()
                
                loadingCounter += 1
            }

            
            
            MyGlobalVariable.timesReloaded_AdvancedSearch = 1 // make sure data isn't reloaded again
        }
        
        // Check for previous search text (view may have been a detail view)
        if searchController.searchBar.text != ""{
            // Filter results based on search text
            filterContent(searchText: searchController.searchBar.text!)
        }
        
        ResultsTable.reloadData()
        
        // Formatting
        ResultsTable.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Check for previous search text (view may have been a detail view)
        if searchController.searchBar.text != "" && self.ResultsTable.contentOffset.y == 0{
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
            
            
            if let indexPath = ResultsTable.indexPathForSelectedRow {
                
                let DestViewController : BugDetailViewController = segue.destination as! BugDetailViewController
                
                if shouldShowSearchResults && searchController.searchBar.text != "" {
                    DestViewController.passedName = bugsSearchResults[indexPath.row]["name"]!
                    DestViewController.passedSearch = searchController.searchBar.text!
                } else {
                    DestViewController.passedName = formattedBugsArray[indexPath.row]["name"]!
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Allow table cell to get bigger to fit wrapped content
        ResultsTable.estimatedRowHeight = 44
        
        // "name" is the only header that MUST be there
        collectionHeaders.append("Name")
        // To set a default collection cell: selectedCollection.append(NSIndexPath(row: 0, section: 0) as IndexPath)
        
        // Set up searchable array with names and details
        //prepareAdvancedSearch()
        /*DispatchQueue.main.async {
            print("Dispatched to background queue 1")
            self.prepareAdvancedSearch()
            self.collectionView.reloadData()
        }*/
        
        
        // Prepare overall background
        self.view.backgroundColor = MyGlobalVariable.themeBackgroundColor
        ResultsTable.backgroundColor = MyGlobalVariable.themeBackgroundColor
        
        // Set background color of bounce area (behind table)
        let bgView = UIView()
        bgView.backgroundColor = MyGlobalVariable.themeBackgroundColor
        self.ResultsTable.backgroundView = bgView
        
        // Prepare collection
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        //layout.minimumInteritemSpacing = 5; // this number could be anything <=5. Need it here because the default is 10.
        
        // Prepare Search
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        ResultsTable.tableHeaderView = searchController.searchBar
        searchController.searchBar.barTintColor = MyGlobalVariable.themeMainColor
        
        // Prepare Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = MyGlobalVariable.themeMainColor
        self.navigationController?.navigationBar.barTintColor = MyGlobalVariable.themeMainColor
        //self.navigationController?.navigationBar.tintColor = MyGlobalVariable.themeLightBlue
        self.title = "Advanced"
        
        // Add button to top right to select all/none
        let allNoneButton   = UIBarButtonItem(title: "All",  style: .plain, target: self, action: #selector(AdvancedSearchViewController.selectAllNone))
        
        navigationItem.rightBarButtonItems = [allNoneButton]
        navigationItem.rightBarButtonItem?.tintColor = MyGlobalVariable.themeBlue
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
