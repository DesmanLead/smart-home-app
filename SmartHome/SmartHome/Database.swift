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
    
    private static let filePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!.URLByAppendingPathComponent("output.csv")
    private var fileHandle: NSFileHandle
    
    init() {
        if !NSFileManager.defaultManager().fileExistsAtPath(Database.filePath.path!) {
            NSFileManager.defaultManager().createFileAtPath(Database.filePath.path!, contents: nil, attributes: nil)
        }
        fileHandle = try! NSFileHandle(forWritingToURL: Database.filePath)
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    private let isolationQueue = dispatch_queue_create("CSV writing queue", DISPATCH_QUEUE_SERIAL)
    
    func setRange(range: Int, beacon: Beacon, time: NSDate) {
        let csv = "\(time.timeIntervalSince1970);\(beacon.uuid);\(range);\(beacon.name)\n"
        print(csv)
        
        dispatch_async(isolationQueue) {
            self.fileHandle.seekToEndOfFile()
            self.fileHandle.writeData(csv.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    
    func dump() {
        print("dump")
        
        dispatch_async(isolationQueue) {
            self.fileHandle.closeFile()
            self.fileHandle = try! NSFileHandle(forWritingToURL: Database.filePath)
        }
    }
    
    func getBeacons() -> [Beacon] {
        return [
            Beacon(name: "WorkBeacon", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF524")
        ]
    }
}