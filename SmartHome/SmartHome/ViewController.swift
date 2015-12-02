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
        
        let db = Database.sharedDatabase()
        Monitor.start(db.getBeacons())
    }
    
    @IBAction func onStop() {
        Monitor.stop()
        
        label.text = "stopped"
    }
    
    override func viewDidLoad() {
        label.text = ""
    }
    
    func onRangeData(notification: NSNotification) {
        label.text = notification.userInfo?.description
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onRangeData:", name: Monitor.RangeNotification.Name, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

