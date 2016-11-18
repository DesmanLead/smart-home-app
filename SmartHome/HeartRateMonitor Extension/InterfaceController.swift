//
//  InterfaceController.swift
//  HeartRateMonitor Extension
//
//  Created by Artem Kirienko on 03.11.16.
//  Copyright © 2016 Artem Kirienko. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate
{
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var button: WKInterfaceButton!
    
    let healthStore = HKHealthStore()
    
    var workoutActive = false
    
    var session: HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    var currenQuery : HKQuery?
    
    // iPhone app connection
    var connectSession: WCSession? = nil
    var isSessionActive: Bool = false
    
    override func willActivate()
    {
        super.willActivate()
        
        guard HKHealthStore.isHealthDataAvailable() else
        {
            heartRateLabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else
        {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes)
        {
            (success, error) -> Void in
            
            if !success
            {
                self.displayNotAllowed()
            }
        }
        
        if connectSession == nil
        {
            connectSession = WCSession.default()
            connectSession?.delegate = self
            connectSession?.activate()
        }
    }
    
    func displayNotAllowed()
    {
        heartRateLabel.setText("not allowed")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date)
    {
        switch toState
        {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error)
    {
        print("Workout error")
    }
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date)
        {
            self.currenQuery = query
            healthStore.execute(query)
        }
        else
        {
            heartRateLabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(_ date : Date)
    {
        healthStore.stop(self.currenQuery!)
        heartRateLabel.setText("---")
        session = nil
    }
    
    @IBAction func startBtnTapped()
    {
        if (self.workoutActive)
        {
            self.workoutActive = false
            self.button.setTitle("Start")
            if let workout = self.session
            {
                healthStore.end(workout)
            }
        }
        else
        {
            self.workoutActive = true
            self.button.setTitle("Stop")
            startWorkout()
        }
        
    }
    
    func startWorkout()
    {
        if (session != nil)
        {
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .crossTraining
        workoutConfiguration.locationType = .indoor
        
        do
        {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
            session?.delegate = self
        }
        catch
        {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(self.session!)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery?
    {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit))
        {
            (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in

            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {
            (query, samples, deleteObjects, newAnchor, error) -> Void in
            
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?)
    {
        guard let heartRateSamples = samples as? [HKQuantitySample] else
        {
            return
        }
        
        guard let sample = heartRateSamples.first else
        {
            return
        }
        
        let value = sample.quantity.doubleValue(for: self.heartRateUnit)
        
        if isSessionActive
        {
            connectSession?.sendMessage(["rate" : value], replyHandler: nil, errorHandler: nil)
        }
        
        DispatchQueue.main.async
        {
            self.heartRateLabel.setText(String(UInt16(value)))
        }
    }
    
    
    // - MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
        guard activationState == .activated else
        {
            print(error?.localizedDescription ?? "unknown error while activating WKSession")
            return
        }
        
        isSessionActive = true
    }
}
