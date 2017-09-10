//
//  SecondViewController.swift
//  Bugs
//
//  Created by Cole Denkensohn on 12/7/16.
//  Copyright © 2016 Cole Denkensohn. All rights reserved.
//
//  Description: ViewController for the More... tab at the bottom right, which displays several accessory pages (static).

import UIKit
import CoreData
import CSVImporter

class MoreInformationViewController: UITableViewController {
    
    @IBOutlet var newUpdateIndicator: UILabel!

    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            // Tapped the rate app cell
            rateApp(appId: "1200033807") { success in
                print("RateApp \(success)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check for update
        if MyGlobalVariable.updateAvailable == true {
            print("Update available!")
            newUpdateIndicator.isHidden = false
        } else{
            newUpdateIndicator.isHidden = true
        }
    
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        newUpdateIndicator.isHidden = true // Hide update indicator by default
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

