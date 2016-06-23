//
//  Database.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation

class Database {
    static let sharedDatabase = Database()
    
    func setRange(_: Int64, beacon: Beacon, time: NSDate) {
        // Save entry to DB
        assertionFailure("Not implemented")
    }
    
    func dump() {
        // Dump database for further investigtion
        assertionFailure("Not implemented")
    }
    
    func getBeacons() -> [Beacon] {
        return [
            Beacon(name: "WorkBeacon", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        ]
    }
}