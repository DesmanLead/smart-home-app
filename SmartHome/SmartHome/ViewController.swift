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
    }
    
    @IBAction func onStop() {
        Monitor.stop(Database.sharedDatabase.getBeacons())
        
        label.text = "stopped"
    }
    
    @IBAction func onDump() {
        Database.sharedDatabase.dump()
    }
    
    override func viewDidLoad() {
        devices = Database.sharedDatabase.getDevices()
        label.text = ""
        devicesTable.dataSource = self
    }
    
    func onRangeData(notification: NSNotification) {
        label.text = notification.userInfo?.description
        
        if let beaconsInfo = notification.userInfo as? [String:[String:AnyObject]] {
            
            let currentTime = NSDate()
            
            for (uuid, parameters) in beaconsInfo {
                guard let rssi = parameters[Monitor.RangeNotification.RSSI] as? Int,
                      let name = parameters[Monitor.RangeNotification.Name] as? String
                else { return }
                
                let beacon = Beacon(name: name, uuid: uuid)
                Database.sharedDatabase.logRange(rssi, forBeacon: beacon, time: currentTime)
            }
        }
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

