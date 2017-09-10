//
//  BugsManager.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/8/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//
//  Description: Contains all of the complex functions needed for getting data from the CSV, parsing it, storing it in the core data, and retrieving it.

import UIKit
import CoreData
import CSVImporter

struct MyGlobalVariable {
    
    static var updateAvailable:Bool = false
    
    // Keep track of loaded data so that it can be grabbed when updates are completed but not every time the view loads
    static var timesReloaded_AdvancedSearch = 0
    static var timesReloaded_BugsTable = 0
    static var timesReloaded_DetailTable = 0
    
    // Global colors
    static let themeBlue = UIColor(red: 66/255, green: 138/255, blue: 255/255, alpha: 1)
    static let themeLightBlue = UIColor(red: 66/255, green: 138/255, blue: 255/255, alpha: 0.4)
    static let themeLightGrey = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
    static let themeMainColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let themeBackgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
}

class BugsManager {
    // Singleton (only instance of this class)
    
    static let sharedInstance = BugsManager()
    
    var window:UIWindow? // Used to reference active view
    
    var bugs = [String]()
    
    var count:Int {
        get  {
            return bugs.count
        }
    }
    
    /*func bugAtIndex (index:Int) -> Void {
        return bugs[index]
    }*/
    
    func fetchBugs(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        request.returnsObjectsAsFaults = false // return as string, not object
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name:String = result.value(forKey: "name") as? String {
                        
                        //print("Name is \(name)")
                        if name != "order"{
                            // Add name to bugs list, as long as it isn't the order row
                            bugs.append(name)
                        }
                        
                    }
                }
                bugs = bugs.sorted { $0 < $1 }
            } else{ // No data in CoreBugsData
                
                print("No data. Grab the data from the included CSV file.")
                // Get data from internal CSV file (shipped with app)
                self.importCSV(dataSource: "internal")
                
                // Check if version number exists in CoreData
                if getVersionNumber() == "update"{
                    setVersionNumber(newVersionNumber: "1.0.53")
                }
            }
            
            
        } catch {
            fatalError("Failed to fetch bugs: \(error)")
        }
        
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // Used in BugDetailViewController to grab the facts about a single bug
    func fetchBugDetails(forBugName:String)->[Dictionary<String, String>]{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        request.returnsObjectsAsFaults = false // return as string, not object
        var returnDetails:[Dictionary<String, String>] = []
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name:String = result.value(forKey: "name") as? String {
                        // Add name to bugs list
                        //bugs.append(name) // UNSURE WHY THIS WAS HERE, MAY NEED TO UNCOMMENT
                        if name == forBugName{
                            
                            //print(result.value(forKey: "attributes"))
                            let dictArray = result.value(forKey: "attributes") as! [Dictionary<String, String>]
                            //print("Details for bug: \(forBugName)")
                            for dict in dictArray {
                                returnDetails.append(dict)
                            }
                            //print(returnDetails)
                            //returnDetails = (result.value(forKey: "attributes") as! NSDictionary) as! Dictionary<String, String>
                        }
                        //print(name)
                        
                    }
                }
            }
            
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        return returnDetails
        
    }
    
    func addBug(newBugName:String, newBugDetails:[[String:String]]){

        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newBug = NSEntityDescription.insertNewObject(forEntityName: "CoreBugsData", into: context)
        newBug.setValue(newBugName, forKey: "name")
        newBug.setValue(newBugDetails, forKey: "attributes")
        
        do {
            
            try context.save()
            //print("Saved")
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
    }
    
    func deleteAllBugs() -> Void {
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreBugsData")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result
        
        for object in resultData! {
            context.delete(object as! NSManagedObject)
        }
        
        do {
            try context.save()
            //print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    func getVersionNumber()->String{
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false // return as string, not object
        var returnVersion = "1.0.x"
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let version:String = result.value(forKey: "version") as? String {
                        
                        returnVersion = version
                        //print("Version from DB: \(version)")
                        
                    }
                }
            } else{
                returnVersion = "update"
                //print("No version in database")
            }
            
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
        return returnVersion
        
    }
    func setVersionNumber(newVersionNumber:String){
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newBug = NSEntityDescription.insertNewObject(forEntityName: "Settings", into: context)
        newBug.setValue(newVersionNumber, forKey: "version")
        
        do {
            
            try context.save()
            //print("Saved version number")
            
        } catch {
            fatalError("Failed to save new bug: \(error)")
        }
        
    }
    func deleteAllSettings() -> Void {
        
        // Get context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        
        let result = try? context.fetch(fetchRequest)
        let resultData = result
        
        for object in resultData! {
            context.delete(object as! NSManagedObject)
        }
        
        do {
            try context.save()
            //print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    //BEGIN: CSV Functions
    var  CSVdata:[[String:String]] = []
    var  CSVcolumnTitles:[String] = []
    
    func getArrayItemsAtHeader(header:String, file:String)->Array<String>{
        convertCSV(file: readDataFromFile(file: file), order: false)
        var bugItemsFromWeb:[String] = []
        for object in CSVdata {
            //print(object)
            if object[header]! == header {
                // Header row, ignore
            } else {
                bugItemsFromWeb.append(object[header]!)
            }
        }
        
        return bugItemsFromWeb
        
    }
    func getArrayDetails(header:String, file:String, initialData:Bool=false)->Array<Any>{
        
        if initialData == true{
            convertCSV(file: readInitialData(file: file))
        } else {
            convertCSV(file: readDataFromFile(file: file))
        }
        var bugDetailsFromWeb:[[String:String]] = []
        for object in CSVdata {
            var cleanObject = object
            if object[header]! == header {
                // Header row, ignore
            } else {
                for nullObject in object { // Look for empty keys (coming from CSV with empty value in row
                    if nullObject.value == ""{
                        //print("Possible null \(nullObject)")
                        cleanObject.removeValue(forKey: nullObject.key)
                    }
                }
                bugDetailsFromWeb.append(cleanObject)
            }
        }
        
        return bugDetailsFromWeb
        
    }
    func cleanRows(file:String)->String{
        //use a uniform \n for end of lines.
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
    
    func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
        return row.components(separatedBy: delimiter)
    }
    
    func convertCSV(file:String, order:Bool=true){
        print("intoConvertCSV")
        let rows = cleanRows(file: file).components(separatedBy: "\n")
        if rows.count > 0 {
            CSVdata = []
            CSVcolumnTitles = getStringFieldsForRow(row: rows.first!,delimiter:",")
            if order == true{
                // Add order of columns as first row
                var orderedHeaders:[String:String] = [:]
                var count:Int = 0
                for key in CSVcolumnTitles{
                    orderedHeaders.updateValue(String(count), forKey: key)
                    count += 1
                }
                CSVdata.append(orderedHeaders)
            }
            for row in rows{
                let fields = getStringFieldsForRow(row: row,delimiter: ",")
                if fields.count != CSVcolumnTitles.count {continue}
                var dataRow = [String:String]()
                for (index,field) in fields.enumerated(){
                    // Replace double space (  ) with a comma
                    dataRow[CSVcolumnTitles[index]] = field.replacingOccurrences(of: "  ", with: ", ")
                }
                CSVdata += [dataRow]
            }
            //print(CSVdata)
            
        } else{
            // Wifi/internet is broken
            CSVdata = [["brokenWifi":"brokenWifi"]]
        }
    }
    
    func readDataFromFile(file:String)-> String!{
        guard let url = URL(string: file)
            //guard let filepath = Bundle.main.path(forResource: file, ofType: "txt")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOf: url)
            //let contents = try String(contentsOfFile: filepath, encoding: String.Encoding.utf8)
            return contents
        } catch {
            // Case where there IS wifi/internet but it doesn't work
            print ("File Read Error")
            return nil
        }
    }
    func readInitialData(file:String)-> String!{
        guard let filepath = Bundle.main.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: String.Encoding.utf8)
            return contents
        } catch {
            print ("File Read Error")
            return nil
        }
    }
    //END: CSV Functions
    
    
    private init() {
        // Fetch bugs from CoreBugsData (or add initial data if empty)
        fetchBugs()
    }
    
    // Begin: Asyncronous CSV functions
    var storedbugs = [String]()
    func importCSV(dataSource:String = "external"){
        
        var bugDetails:[[String:String]] = []
        var bugNames:[String] = []
        bugNames.append("0") // Since this is the name column and it always goes first, insert 0 to represent its order
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrl = documentsUrl.appendingPathComponent("data.csv")
        
        var fileURLImporter = CSVImporter<[String: String]>(url: destinationFileUrl)
        
        // On first app launch, the system will see an empty core data and want to fill it with the CSV (InitialData.csv) that shipped with the app rather than getting data from the web
        if dataSource == "internal"{
            let bundle = Bundle.main
            let path = bundle.path(forResource: "InitialData", ofType: "csv")
            fileURLImporter = CSVImporter<[String: String]>(path: path!)
        }
        
        fileURLImporter?.startImportingRecords(structure: { (headerValues) -> Void in
            
            //print("Headers: \(headerValues)") // => ["Name", "Type" ... ]
            // Set order of headers // ["Laboratory": "5", "Signs": "8", "Name": "0", ...]
            var orderedHeaders:[String:String] = [:]
            var count:Int = 0
            for key in headerValues{
                orderedHeaders.updateValue(String(count), forKey: key)
                count += 1
            }
            bugDetails.append(orderedHeaders)
            
        }) { $0 }.onFail {
            
            print("The CSV file couldn't be read.")
            
            }.onProgress { importedDataLinesCount in
                
                //print("\(importedDataLinesCount) lines were already imported.")
                
            }.onFinish { importedRecords in
                
                print("Did finish import with \(importedRecords.count) records.")
                
                var recNum = 0
                // Fill bugDetails
                for record in importedRecords {
                    //print("Here is the data for #\(recNum): \(record)") // => e.g. ["firstName": "Harry", "lastName": "Potter"]
                    //print(record["firstName"]) // prints "Harry" on first, "Hermione" on second run
                    //print(record["lastName"]) // prints "Potter" on first, "Granger" on second run
                    
                    // Look for empty keys (coming from CSV with empty value in row
                    var cleanRecord = record
                    for nullObject in record {
                        if nullObject.value == ""{
                            cleanRecord.removeValue(forKey: nullObject.key)
                        }
                    }
                    
                    // Fill bugDetails
                    bugDetails.append(cleanRecord)
                    
                    // Fill bugNames
                    bugNames.append(cleanRecord["Name"]!)
                    
                    
                    recNum += 1
                }
                
                //print("Bug Details from CSV: \(bugDetails)")
                //print("Bug Names from CSV: \(bugNames)")
                
                // Delete CoreBugsData to make room for the new data
                self.deleteAllBugs()
                
                /* The difficulty here is that Dictionary Arrays are not ordered, but we need to get the data columns in the same order as the Admin inputs them (i.e. General should come before Treatment). The solution was to store the column headers as soon as they come in in the correct order and then loop through the dictionary adding it as a nested array to maintain the order. */
                var orderedHeaders:[String] = []
                for (name, details) in zip(bugNames, bugDetails) {
                    var detailsR = details
                    detailsR.removeValue(forKey: "Name") // No need to store bug name in details
                    var checkname = name
                    var finalOrderedDictionary:[[String:String]] = []
                    if checkname == String(0) {
                        checkname = "order"
                        
                        // Must cast comparison as Int() before comparing so that double digit numbers are ordered properly
                        let orderedDetailsR = detailsR.sorted{ Int($0.value)! < Int($1.value)! }

                        
                        for (key,_) in orderedDetailsR {
                            orderedHeaders.append(key)
                        }
                    } else{
                        checkname = name
                    }
                    for key in orderedHeaders{
                        if detailsR[key] != nil {
                            finalOrderedDictionary.append([key:detailsR[key]!])
                        }
                        
                    }
                    //print("Ordered headers: \(orderedHeaders)")
                    if checkname == "order"{ continue }
                    //print("New bug name: \(name) AND New bug details: \(finalOrderedDictionary)")
                    
                    
                    // Finally, add new bug
                    self.addBug(newBugName: name, newBugDetails: finalOrderedDictionary)
                    //self.storedbugs.append(name)
                }
                /*if self.bugs.count > 0{
                    print("Found bugs!")
                } else{
                    print("No bugs in sight...")
                    self.bugs = self.storedbugs
                }*/
        }
        
        
    }
    
    func downloadNewData(webURL:String){
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        
        let destinationFileUrl = documentsUrl.appendingPathComponent("data.csv")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("data.csv")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            print("data.csv already exists - removing it now in order to download a new version")
            do {
                try fileManager.removeItem(atPath: filePath!)
            }
            catch let error as NSError {
                print("File could not be removed: \(error)")
            }
        } else {
            print("data.csv does not exists - downloadig it now")
        }
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: webURL)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded data.csv. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
                // Get data.csv data
                self.importCSV()
                
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "unclear");
            }
        }
        task.resume()
    }
    // End: Asyncronous CSV functions
}
