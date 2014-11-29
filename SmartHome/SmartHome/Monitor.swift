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
    class LocationHandler: NSObject, CLLocationManagerDelegate {
        func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            for beacon: CLBeacon in beacons as [CLBeacon] {
                println("DEADBEEF id.: \(region.identifier); prox.: \(beacon.proximity)")
            }
        }
    }
    
    private class func locationManager() -> CLLocationManager {
        struct Holder {
            static let instance: CLLocationManager = CLLocationManager()
        }
        
        return Holder.instance
    }
    
    class func start(beacons: [Beacon]) -> LocationHandler {
        stop()
        
        let beaconUUID = NSUUID(UUIDString: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        let beaconIdentifier = "WorkBeacon"
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier:beaconIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true
        
        let lm = locationManager()
        let handler = LocationHandler()
        lm.delegate = handler
        lm.startMonitoringForRegion(beaconRegion)
        lm.startRangingBeaconsInRegion(beaconRegion)
        
        return handler
    }
    
    class func stop() {
        let lm = locationManager()
        
        let beaconUUID = NSUUID(UUIDString: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        let beaconIdentifier = "WorkBeacon"
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier:beaconIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true

        lm.stopRangingBeaconsInRegion(beaconRegion)
        lm.stopMonitoringForRegion(beaconRegion)
    }
}