//
//  ViewController.swift
//  SmartHome
//
//  Created by Artem Kirienko on 29.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDataSource
{
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var devicesTable: UITableView!
    var devices: [Device]!
    var discoveredBeaconUuids: Set<String> = []
    var isStarted: Bool = false
    
    @IBAction func onStart()
    {
        isStarted = true
        label.text = "started"
        
        Monitor.start(Database.sharedDatabase.getBeacons())
        HeartRateMonitor.sharedMonitor.start()
    }
    
    @IBAction func onStop()
    {
        isStarted = false
        Monitor.stop(Database.sharedDatabase.getBeacons())
        HeartRateMonitor.sharedMonitor.stop()
        
        discoveredBeaconUuids = []
        
        label.text = "stopped"
    }
    
    @IBAction func onDump()
    {
        Database.sharedDatabase.dump()
        
        label.text = "dumped"
    }
    
    override func viewDidLoad()
    {
        devices = Database.sharedDatabase.getDevices()
        label.text = ""
        devicesTable.dataSource = self
        
        self.updateUI()
        
        self.requestHeartRatePermission()
    }
    
    func requestHeartRatePermission()
    {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else
        {
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        HKHealthStore().requestAuthorization(toShare: nil, read: dataTypes)
        {
            (success, error) -> Void in
            
            if !success
            {
                self.label.text = "Unable to get heart rate permission"
            }
        }

    }
    
    func onRangeData(_ notification: Notification)
    {
        guard let userInfo = notification.userInfo as? [String: Any] else
        {
            return
        }
        
        DispatchQueue.main.async
        {
            if self.isStarted
            {
                self.discoveredBeaconUuids.formUnion(userInfo.keys)
                
                self.label.text = "Discovered \(self.discoveredBeaconUuids.count) beacons"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onRangeData(_:)), name: NSNotification.Name(rawValue: Monitor.RangeNotification.Name), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") as? DeviceTableCell else { fatalError() }
        
        let index = indexPath.row
        let device = devices[index]
        
        cell.deviceName = device.name
        cell.deviceEnabled = device.isEnabled
        
        cell.onDeviceEnabled = {
            isEnabled in
            
            var updatedDevice = device
            updatedDevice.isEnabled = isEnabled
            self.devices[index] = updatedDevice
            Database.sharedDatabase.logDeviceState(updatedDevice, time: Date.timeIntervalSinceReferenceDate)
            
            self.updateUI()
        }
        
        return cell
    }
    
    private func updateUI()
    {
        devices.sort
        {
            lhs, rhs in
            
            if lhs.isEnabled == rhs.isEnabled
            {
                return lhs.name.compare(rhs.name) == .orderedAscending
            }
            
            return lhs.isEnabled
        }
        
        self.devicesTable.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}

