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
    
    
    private class LocationHandler: NSObject, CLLocationManagerDelegate {
        @objc func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
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
    
    private static var handler: LocationHandler?
    
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
    }
}