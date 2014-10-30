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
    class func start(beacons: [Beacon]) {
        stop()
        
        let beaconUUID = NSUUID(UUIDString: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        let beaconIdentifier = "WorkBeacon"
        let beaconRegion = CLBeaconRegion(proximityUUID: beaconUUID, identifier:beaconIdentifier)
    }
    
    class func stop() {
    }
}