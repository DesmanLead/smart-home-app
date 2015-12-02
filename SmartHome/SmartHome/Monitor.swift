//
//  Monitor.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation
import CoreLocation

class Monitor {
    struct RangeNotification {
        static let Name       = "SHRangeNotification"
        static let Identifier = "SHRangeNotificationIdentifier"
        static let Proximity  = "SHRangeNotificationProximity"
        static let RSSI       = "SHRangeNotificationRSSI"
    }
    
    
    class LocationHandler: NSObject, CLLocationManagerDelegate {
        func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
            for beacon: CLBeacon in beacons {                
                let userInfo: [ NSObject : AnyObject ] = [
                    RangeNotification.Identifier : region.identifier,
                    RangeNotification.Proximity  : beacon.proximity.rawValue,
                    RangeNotification.RSSI  : beacon.rssi
                ]

                let notification = NSNotification(name: RangeNotification.Name, object: self, userInfo: userInfo)
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotification(notification)
            }
        }
    }
    
    private class func locationManager() -> CLLocationManager {
        struct Holder {
            static let instance: CLLocationManager = CLLocationManager()
        }
        
        return Holder.instance
    }
    
    static var handler: LocationHandler?
    
    class func start(beacons: [Beacon]) {
        stop()
        
        let beaconUUID = NSUUID(UUIDString: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        let beaconIdentifier = "WorkBeacon"
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true
        
        let lm = locationManager()
        let handler = LocationHandler()
        lm.delegate = handler
        lm.startMonitoringForRegion(beaconRegion)
        lm.startRangingBeaconsInRegion(beaconRegion)
        
        self.handler = handler
    }
    
    class func stop() {
        let lm = locationManager()
        
        let beaconUUID = NSUUID(UUIDString: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        let beaconIdentifier = "WorkBeacon"
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!, identifier:beaconIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true

        lm.stopRangingBeaconsInRegion(beaconRegion)
        lm.stopMonitoringForRegion(beaconRegion)
        
        self.handler = nil
    }
}