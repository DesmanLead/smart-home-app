//
//  HeartRateMonitor.swift
//  SmartHome
//
//  Created by Artem Kirienko on 13.09.16.
//  Copyright © 2016 Desman. All rights reserved.
//

import Foundation
import HealthKit
import WatchConnectivity

class HeartRateMonitor: NSObject, WCSessionDelegate
{
    static let sharedMonitor = HeartRateMonitor()
    
    private var session: WCSession?
    
    func start()
    {
        if session == nil
        {
            session = WCSession.default()
            session?.delegate = self
            session?.activate()
        }
    }
    
    func stop()
    {
        // Not required yet
    }
    
    // - MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
        guard activationState == .activated else
        {
            print(error?.localizedDescription ?? "unknow error while activating WCSession")
            return
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession)
    {
        // No need to support
    }
    
    func sessionDidDeactivate(_ session: WCSession)
    {
        // No need to support
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    {
        guard let heartRate = message["rate"] as? Double else
        {
            print("unexpected message: \(message)")
            return
        }
        
        print("rate: \(heartRate)")
        Database.sharedDatabase.logHeartRate(rate: heartRate, time: Date.timeIntervalSinceReferenceDate)
    }
}
