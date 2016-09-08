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
    
    private static let Delimiter = ","
    
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
    
    private func writeLine(line: String) {
        let processedLine = line + "\n"
        
        dispatch_async(isolationQueue) {
            self.fileHandle.seekToEndOfFile()
            self.fileHandle.writeData(processedLine.dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    
    func logRange(range: Int, forBeacon beacon: Beacon, time: NSTimeInterval) {
        let csv = [
            "\(time)",
            beacon.uuid,
            "\(range)",
            beacon.name
        ].joinWithSeparator(Database.Delimiter)
        
        writeLine(csv)
    }
    
    func logDeviceState(device: Device, time: NSDate) {
        let csv = [
            "\(time.timeIntervalSince1970)",
            device.identifier,
            "\(device.isEnabled ? 1 : 0)",
            device.name
        ].joinWithSeparator(Database.Delimiter)
        
        writeLine(csv)
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
            Beacon(name: "WorkBeacon", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF524", supportsIBeacon: true),
            Beacon(name: "Apple TV", uuid: "ATV00", supportsIBeacon: false)
        ]
    }
    
    func getDevices() -> [Device] {
        return [
            Device(name: "Kitchen Light", isEnabled: false),
            Device(name: "Bedroom Light", isEnabled: false),
            Device(name: "Bathroom Light", isEnabled: false),
            Device(name: "Toilet Light", isEnabled: false),
            Device(name: "Hall Light", isEnabled: false)
        ]
    }
}