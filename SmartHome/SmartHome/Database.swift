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
    
    private static let filePathBase = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    private var fileHandle: NSFileHandle!
    
    init() {
        self.createFile()
    }
    
    deinit {
        fileHandle.closeFile()
    }
    
    private let isolationQueue = dispatch_queue_create("CSV writing queue", DISPATCH_QUEUE_SERIAL)
    
    private func createFile() {
        let filePath = Database.filePathBase.URLByAppendingPathComponent("\(NSDate().description).csv")
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath.path!) {
            NSFileManager.defaultManager().createFileAtPath(filePath.path!, contents: nil, attributes: nil)
        }
        fileHandle = try! NSFileHandle(forWritingToURL: filePath)
    }
    
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
        dispatch_async(isolationQueue) {
            self.fileHandle.closeFile()
            self.createFile()
        }
    }
    
    func getBeacons() -> [Beacon] {
        return [
            Beacon(name: "WorkBeacon", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF524", supportsIBeacon: true),
            Beacon(name: "Apple TV", uuid: "3ec3d2ca-4624-4943-a2f6-69e222c57393", supportsIBeacon: false),
            Beacon(name: "MI_SCALE", uuid: "bc3c94b6-9c70-4e2c-9205-0b5d3476c7d6", supportsIBeacon: false)
        ]
    }
    
    func getDevices() -> [Device] {
        return [
            Device(identifier: "c2bc678c-ed73-45c6-8804-bcaf645f0891", name: "Kitchen Light", isEnabled: false),
            Device(identifier: "ed646245-3030-4251-8320-14e228fed987", name: "Bedroom Light", isEnabled: false),
            Device(identifier: "66ca0cbc-6d48-4264-be78-8914412f27ed", name: "Bathroom Light", isEnabled: false),
            Device(identifier: "42c46854-3ddd-4896-b271-c051e4edacb8", name: "Toilet Light", isEnabled: false),
            Device(identifier: "12421fda-3bfd-4eda-8534-ca7f5ba8bf8f", name: "Hall Light", isEnabled: false)
        ]
    }
}