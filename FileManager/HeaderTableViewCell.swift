//
//  HeaderTableViewCell.swift
//  FileManager
//
//  Created by Subin Kuriakose on 31/12/15.
//  Copyright © 2015 Vineeth Vijayan. All rights reserved.
//

import UIKit
import Foundation

class HeaderTableViewCell: UITableViewController {
    
    
    @IBOutlet var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        _tableView.dataSource = self
        _tableView.delegate = self
        
        _tableView.reloadData()
        
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
             let view = HeaderView()
            return view
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
     
        return 50.0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = _tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! headerCell
        return cell
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

}
