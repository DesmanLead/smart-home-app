//
//  ViewController.swift
//  SmartHome
//
//  Created by Artem Kirienko on 29.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    @IBAction func onStart() {
        label.text = "started"
        
        Monitor.start(Database.sharedDatabase.getBeacons())
    }
    
    @IBAction func onStop() {
        Monitor.stop(Database.sharedDatabase.getBeacons())
        
        label.text = "stopped"
    }
    
    override func viewDidLoad() {
        label.text = ""
    }
    
    func onRangeData(notification: NSNotification) {
        label.text = notification.userInfo?.description
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onRangeData(_:)), name: Monitor.RangeNotification.Name, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

