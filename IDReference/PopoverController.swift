//
//  PopoverController.swift
//  IDReference
//
//  Created by Cole Denkensohn on 7/30/17.
//
//

import Foundation
import UIKit


class PopoverController: UITableViewController {
    
    static var popoverOptions:[String] = ["default"]
    
    @IBOutlet var popoverTable: UITableView!
    
    // Set up delegate to send data back to parent view from popover
    weak var delegate: myPopoverDelegate? //= BugDetailViewController()
    
    // Table View Data Source Method
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PopoverController.popoverOptions.count // Get number of bugs from BugsManager
        
    }
    
    // Provide a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "popoverTableCell", for: indexPath as IndexPath)
        
        let cellText = PopoverController.popoverOptions[indexPath.row].components(separatedBy: ",")
        
        cell.textLabel?.text = cellText[0]
        
        // Add left image based on type
        let imagename:String = "popoverImage_"+cellText[1]
        let image : UIImage = UIImage(named: imagename)! //.withRenderingMode(.alwaysTemplate)
        
        cell.imageView?.image = image
        //cell.imageView?.tintColor = UIColor.blue
        
        return cell
        
    }
    
    // User taps table cell
    var cellAction:[String] = ["default"]
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get action data (vs. text) from array
        cellAction = PopoverController.popoverOptions[indexPath.row].components(separatedBy: ",")

        // Dismiss popover
        self.dismiss(animated: false, completion: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        // Wait until popover has disappeared to call the action
        if cellAction[0] != "default"{
            self.delegate?.sentPopoverData(option: cellAction[1])
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let popoverTableRowHeight = 44
        popoverTable.estimatedRowHeight = CGFloat(popoverTableRowHeight)
        popoverTable.alwaysBounceVertical = false
        
        let height = PopoverController.popoverOptions.count * Int(popoverTableRowHeight + 4)
        self.preferredContentSize = CGSize(width: 200, height: height)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

