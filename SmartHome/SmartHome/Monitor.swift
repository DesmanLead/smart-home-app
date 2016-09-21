//
//  Monitor.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

class Monitor
{
    struct RangeNotification
    {
        static let Name       = "SHRangeNotification"
        static let Identifier = "SHRangeNotificationIdentifier"
        static let Proximity  = "SHRangeNotificationProximity"
        static let RSSI       = "SHRangeNotificationRSSI"
    }
    
    // MARK: - iBeacons handler
    
    private class LocationHandler: NSObject, CLLocationManagerDelegate
    {
        @objc func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
        {
            var userInfo: [AnyHashable: Any] = [:]
            
            let currentTime = Date.timeIntervalSinceReferenceDate
            
            for beacon: CLBeacon in beacons
            {
                // Log to DB
                let dbBeacon = Beacon(name: region.identifier, uuid: beacon.proximityUUID.uuidString, supportsIBeacon: true)
                Database.sharedDatabase.logRange(beacon.rssi, forBeacon: dbBeacon, time: currentTime)
                
                // Broadcast notification
                let beaconInfo: [AnyHashable: Any] =
                [
                    RangeNotification.Name : region.identifier,
                    RangeNotification.Proximity  : beacon.proximity.rawValue,
                    RangeNotification.RSSI  : beacon.rssi
                ]
                
                userInfo[beacon.proximityUUID.uuidString] = beaconInfo
            }
            
            let notification = Notification(name: Notification.Name(rawValue: RangeNotification.Name), object: self, userInfo: userInfo)
            let nc = NotificationCenter.default
            nc.post(notification)
        }
    }
    
    private class func locationManager() -> CLLocationManager
    {
        struct Holder
        {
            static let instance: CLLocationManager = CLLocationManager()
        }
        
        return Holder.instance
    }
    
    private static var handler: LocationHandler?
    
    // MARK: - Bluetooth Devices handler
    
    private class BluetoothDevicesHandler: NSObject, CBCentralManagerDelegate
    {
        private var devices: [String: Beacon]
        
        init(devices: [Beacon])
        {
            self.devices = [:]
            
            for device in devices
            {
                self.devices[device.name] = device
            }
        }
        
        @objc fileprivate func centralManagerDidUpdateState(_ central: CBCentralManager)
        {
            if central.state == .poweredOn
            {
                central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
            else
            {
                print(central.state)
            }
        }
        
        @objc fileprivate func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
        {
            if let name = peripheral.name,
               let device = devices[name]
            {
                let currentTime = Date.timeIntervalSinceReferenceDate
                Database.sharedDatabase.logRange(RSSI.intValue, forBeacon: device, time: currentTime)
            }
        }
    }
    
    private static var bluetoothCentralManager: CBCentralManager?
    private static var bluetoothDevicesHandler: BluetoothDevicesHandler?
    
    // MARK: - Monotoring control
    
    class func start(_ beacons: [Beacon])
    {
        stop(beacons)
        
        let lm = locationManager()
        lm.requestAlwaysAuthorization()
        
        let handler = LocationHandler()
        lm.delegate = handler
        
        for beacon in beacons
        {
            if !beacon.supportsIBeacon
            {
                continue
            }
            
            let beaconUUID = UUID(uuidString: beacon.uuid)
            let beaconIdentifier = beacon.name
            let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
            beaconRegion.notifyEntryStateOnDisplay = true
            
            lm.startMonitoring(for: beaconRegion)
            lm.startRangingBeacons(in: beaconRegion)
        }
        
        self.handler = handler
        
        
        bluetoothDevicesHandler = BluetoothDevicesHandler(devices: beacons.filter { !$0.supportsIBeacon })
        bluetoothCentralManager = CBCentralManager(delegate: bluetoothDevicesHandler, queue: nil)
    }
    
    class func stop(_ beacons: [Beacon])
    {
        let lm = locationManager()
        
        for beacon in beacons
        {
            if !beacon.supportsIBeacon
            {
                continue
            }
            
            let beaconUUID = UUID(uuidString: beacon.uuid)
            let beaconIdentifier = beacon.name
            let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
            beaconRegion.notifyEntryStateOnDisplay = true

            lm.stopRangingBeacons(in: beaconRegion)
            lm.stopMonitoring(for: beaconRegion)
        }
        
        bluetoothCentralManager?.stopScan()
    }
}
