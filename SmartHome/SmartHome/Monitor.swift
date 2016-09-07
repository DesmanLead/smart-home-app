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

class Monitor {
    struct RangeNotification {
        static let Name       = "SHRangeNotification"
        static let Identifier = "SHRangeNotificationIdentifier"
        static let Proximity  = "SHRangeNotificationProximity"
        static let RSSI       = "SHRangeNotificationRSSI"
    }
    
    // MARK: - iBeacons handler
    
    private class LocationHandler: NSObject, CLLocationManagerDelegate {
        @objc func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
            var userInfo: [NSObject:AnyObject] = [:]
            
            for beacon: CLBeacon in beacons {                
                let beaconInfo: [NSObject:AnyObject] = [
//                    RangeNotification.Identifier : beacon.proximityUUID.UUIDString,
                    RangeNotification.Name : region.identifier,
                    RangeNotification.Proximity  : beacon.proximity.rawValue,
                    RangeNotification.RSSI  : beacon.rssi
                ]
                
                userInfo[beacon.proximityUUID.UUIDString] = beaconInfo
            }
            
            let notification = NSNotification(name: RangeNotification.Name, object: self, userInfo: userInfo)
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotification(notification)
        }
    }
    
    private class func locationManager() -> CLLocationManager {
        struct Holder {
            static let instance: CLLocationManager = CLLocationManager()
        }
        
        return Holder.instance
    }
    
    private static var handler: LocationHandler?
    
    // MARK: - Bluetooth Devices handler
    
    private class BluetoothDevicesHandler: NSObject, CBCentralManagerDelegate {
        @objc private func centralManagerDidUpdateState(central: CBCentralManager) {
            if central.state == .PoweredOn {
                central.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            }
            else {
                print(central.state)
            }
        }
        
        @objc private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
            print("\(peripheral.name) : \(RSSI)")
        }
    }
    
    private static var bluetoothCentralManager: CBCentralManager?
    private static var bluetoothDevicesHandler: BluetoothDevicesHandler?
    
    // MARK: - Monotoring control
    
    class func start(beacons: [Beacon]) {
        stop(beacons)
        
        let lm = locationManager()
        lm.requestAlwaysAuthorization()
        
        let handler = LocationHandler()
        lm.delegate = handler
        
        for beacon in beacons {
            let beaconUUID = NSUUID(UUIDString: beacon.uuid)
            let beaconIdentifier = beacon.name
            let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
            beaconRegion.notifyEntryStateOnDisplay = true
            
            lm.startMonitoringForRegion(beaconRegion)
            lm.startRangingBeaconsInRegion(beaconRegion)
        }
        
        self.handler = handler
        
        
        bluetoothDevicesHandler = BluetoothDevicesHandler()
        bluetoothCentralManager = CBCentralManager(delegate: bluetoothDevicesHandler, queue: nil)
    }
    
    class func stop(beacons: [Beacon]) {
        let lm = locationManager()
        
        for beacon in beacons {
            let beaconUUID = NSUUID(UUIDString: beacon.uuid)
            let beaconIdentifier = beacon.name
            let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
            beaconRegion.notifyEntryStateOnDisplay = true

            lm.stopRangingBeaconsInRegion(beaconRegion)
            lm.stopMonitoringForRegion(beaconRegion)
        }
        
        self.handler = nil
        
        
        bluetoothCentralManager?.stopScan()
        bluetoothDevicesHandler = nil
        bluetoothCentralManager = nil
    }
}