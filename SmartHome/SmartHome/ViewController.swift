//
//  ViewController.swift
//  SmartHome
//
//  Created by Artem Kirienko on 29.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var devicesTable: UITableView!
    var devices: [Device]!
    
    @IBAction func onStart() {
        label.text = "started"
        
        Monitor.start(Database.sharedDatabase.getBeacons())
        HeartRateMonitor.sharedMonitor.start()
    }
    
    @IBAction func onStop() {
        Monitor.stop(Database.sharedDatabase.getBeacons())
        HeartRateMonitor.sharedMonitor.stop()
        
        label.text = "stopped"
    }
    
    @IBAction func onDump() {
        Database.sharedDatabase.dump()
        
        label.text = "dumped"
    }
    
    override func viewDidLoad() {
        devices = Database.sharedDatabase.getDevices()
        label.text = ""
        devicesTable.dataSource = self
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
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("deviceCell") as? DeviceTableCell else { fatalError() }
        
        let device = devices[indexPath.row]
        
        cell.deviceName = device.name
        cell.deviceEnabled = device.isEnabled
        
        cell.onDeviceEnabled = {
            isEnabled in
            
            var updatedDevice = device
            updatedDevice.isEnabled = isEnabled
            Database.sharedDatabase.logDeviceState(updatedDevice, time: NSDate())
        }
        
        return cell
    }
}

