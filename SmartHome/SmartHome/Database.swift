//
//  Database.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation

class Database {
    class func sharedDatabase() -> Database {
        struct Holder {
            static let instance : Database = Database()
        }
        
        return Holder.instance
    }
    
    func setRange(Int64, beacon: Beacon, time: TimeValue64) {
        // Save entry to DB
        assertionFailure("Not implemented")
    }
    
    func dump() {
        // Dump database for further investigtion
        assertionFailure("Not implemented")
    }
    
    func getBeacons() -> [Beacon] {
        return [
            Beacon(name: "WorkBeacon", uuid: "")
        ]
    }
}