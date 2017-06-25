//
//  Database.swift
//  SmartHome
//
//  Created by Artem Kirienko on 30.10.14.
//  Copyright (c) 2014 Desman. All rights reserved.
//

import Foundation

class Database
{
    static let sharedDatabase = Database()
    
    private static let Delimiter = ","
    
    private static let filePathBase = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    private var fileHandle: FileHandle!
    private var observationStartDate: NSDate!
    
    init()
    {
        self.createFile()
    }
    
    deinit
    {
        fileHandle.closeFile()
    }
    
    private let isolationQueue = DispatchQueue(label: "CSV writing queue", attributes: [])
    
    private func createFile()
    {
        observationStartDate = NSDate()
        let filePath = Database.filePathBase.appendingPathComponent("\(observationStartDate.description).csv")
        if !FileManager.default.fileExists(atPath: filePath.path)
        {
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
        }
        fileHandle = try! FileHandle(forWritingTo: filePath)
    }
    
    private func writeLine(_ line: String)
    {
        let processedLine = line + "\n"
        
        isolationQueue.async {
            self.fileHandle.seekToEndOfFile()
            self.fileHandle.write(processedLine.data(using: String.Encoding.utf8)!)
        }
    }
    
    func logRange(_ range: Int, forBeacon beacon: Beacon, time: TimeInterval)
    {
        let csv = [
            "\(time)",
            beacon.uuid,
            "\(range)",
            beacon.name
        ].joined(separator: Database.Delimiter)
        
        writeLine(csv)
    }
    
    func logDeviceState(_ device: Device, time: TimeInterval)
    {
        let csv = [
            "\(time)",
            device.identifier,
            "\(device.isEnabled ? 1 : 0)",
            device.name
        ].joined(separator: Database.Delimiter)
        
        writeLine(csv)
    }
    
    func logActivity(_ activity: Activity, time: TimeInterval)
    {
        let csv = [
            "\(time)",
            activity.identifier,
            "\(activity.isStarted ? 1 : 0)",
            activity.name
            ].joined(separator: Database.Delimiter)
        
        writeLine(csv)
    }
    
    func logHeartRate(rate: Double, time: TimeInterval)
    {
        let csv = [
            "\(time)",
            "d9114d7c-6168-4471-805e-95c5ed325dc5",
            "\(rate)",
            "Heart Rate Sensor"
        ].joined(separator: Database.Delimiter)
        
        writeLine(csv)
    }
    
    func dump()
    {
        isolationQueue.async {
            self.fileHandle.closeFile()
            self.createFile()
        }
    }
    
    func getBeacons() -> [Beacon]
    {
        return [
            Beacon(name: "KitchenBeacon0", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF524", supportsIBeacon: true),
            Beacon(name: "BedroomBeacon1", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF525", supportsIBeacon: true),
            Beacon(name: "ToiletBeacon2", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF526", supportsIBeacon: true),
            Beacon(name: "BathroomBeacon3", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF527", supportsIBeacon: true),
            Beacon(name: "KitchenBeacon4", uuid: "EBEFD083-70A2-47C8-9837-E7B5634DF528", supportsIBeacon: true),
            Beacon(name: "Apple TV", uuid: "3ec3d2ca-4624-4943-a2f6-69e222c57393", supportsIBeacon: false),
            Beacon(name: "MI_SCALE", uuid: "bc3c94b6-9c70-4e2c-9205-0b5d3476c7d6", supportsIBeacon: false)
        ]
    }
    
    func getDevices() -> [Device]
    {
        return [
            Device(identifier: "c2bc678c-ed73-45c6-8804-bcaf645f0891", name: "Kitchen Light", isEnabled: false),
            Device(identifier: "1b0ada96-f4e0-4edc-8441-d0ed12d9ba53", name: "Kitchen Water Light", isEnabled: false),
            Device(identifier: "1b0ada96-f4e0-4edc-8441-d0ed12d9ba53", name: "Kitchen Local Light", isEnabled: false),
            Device(identifier: "0b6889f4-b87c-46c5-98c9-b8c3263cd8eb", name: "Kitchen Kettle", isEnabled: false),
            Device(identifier: "ed646245-3030-4251-8320-14e228fed987", name: "Bedroom Light", isEnabled: false),
            Device(identifier: "9660cb58-ab9f-448b-add8-ed5d76e3de66", name: "Bedroom Local Light", isEnabled: false),
            Device(identifier: "42c46854-3ddd-4896-b271-c051e4edacb8", name: "Toilet Light", isEnabled: false),
            Device(identifier: "12421fda-3bfd-4eda-8534-ca7f5ba8bf8f", name: "Hall Light", isEnabled: false),
            Device(identifier: "dcdb6cef-f9b3-461e-81b2-54ad37736ef4", name: "Kitchen Water", isEnabled: false),
            Device(identifier: "4faee1a1-d3d7-48c7-a097-42bcdd87e9a9", name: "Kitchen Cooker", isEnabled: false),
            Device(identifier: "35cf38bf-693e-412b-89ac-88a5998f66c0", name: "Computer", isEnabled: false),
            Device(identifier: "889f3ef1-4c37-4f79-b19b-e78e512b82dd", name: "Music", isEnabled: false)
        ]
    }
    
    func getActivities() -> [Activity]
    {
        return [
            Activity(identifier: "7c5d5f96-4667-4d35-9bf1-4cf604e2bc35", name: "Working with computer", isStarted: false),
            Activity(identifier: "def2c8f2-a7ea-47a4-a58a-a5544e917023", name: "Rest with computer", isStarted: false),
            Activity(identifier: "c1678225-c5cf-4399-ad48-0703dc718a86", name: "Shower", isStarted: false),
            Activity(identifier: "3db877ff-bd74-4ddc-a3ec-939c57b364a3", name: "Washing hands", isStarted: false),
            Activity(identifier: "65865b45-765b-4038-9e92-d9a5c358fba9", name: "Breakfast", isStarted: false),
            Activity(identifier: "7ba1ee75-a15f-467a-8bdc-9cb49efdef77", name: "Dinner", isStarted: false),
            Activity(identifier: "f3ea9886-d956-4a7a-b9c4-95edaba56e13", name: "Cooking breakfast", isStarted: false),
            Activity(identifier: "ba0f9491-dea3-4059-b4ad-7bd08cabe1aa", name: "Cooking dinner", isStarted: false),
            Activity(identifier: "7e9cac8b-cca2-4396-b325-23edc21fde3a", name: "Toilet", isStarted: false),
            Activity(identifier: "4174d1ab-cbe7-44e8-a72e-4d6b04ae7eb7", name: "Entered home", isStarted: false),
            Activity(identifier: "5d98492f-f954-4419-a59f-d53d9fd44ef9", name: "Leaving home", isStarted: false),
            Activity(identifier: "6242f8db-b666-4f50-8b64-05435d601aa7", name: "Preparing to sleep", isStarted: false),
            Activity(identifier: "95eddaf9-69be-41bc-9eaf-6a4e524ba48e", name: "Washing dishes", isStarted: false)
        ]
    }
}
