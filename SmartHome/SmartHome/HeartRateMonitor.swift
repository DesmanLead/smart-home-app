//
//  HeartRateMonitor.swift
//  SmartHome
//
//  Created by Artem Kirienko on 13.09.16.
//  Copyright © 2016 Desman. All rights reserved.
//

import Foundation
import HealthKit

class HeartRateMonitor
{
    static let sharedMonitor = HeartRateMonitor()
    
    private let healthKitStore = HKHealthStore()
    private var query: HKQuery?
    
    func start()
    {
        let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let heartRateUnit = HKUnit(from: "count/min")
        let healthKitTypes: Set = [ heartRateType ]

        healthKitStore.requestAuthorization(toShare: nil, read: healthKitTypes) {
            _, _ in
            
            let queryPredicate  = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-600), end: nil, options: [])

            let query: HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: heartRateType,
                                                                     predicate: queryPredicate,
                                                                     anchor: nil,
                                                                     limit: HKObjectQueryNoLimit) {
                query, samples, deletedObjects, anchor, error in

                if let errorFound = error
                {
                    print("query error: \(errorFound.localizedDescription)")
                    return
                }

                guard let samples = samples else
                {
                    return
                }

                for sample in samples
                {
                    if let quantitySample = sample as? HKQuantitySample
                    {
                        let heartRate = quantitySample.quantity.doubleValue(for: heartRateUnit)
                        let time = quantitySample.endDate
                        
                        print("\(quantitySample.startDate) — \(time) : \(heartRate)")
                        Database.sharedDatabase.logHeartRate(rate: heartRate, time: time.timeIntervalSinceReferenceDate)
                    }
                }
            }
            
            query.updateHandler = {
                query, samples, deletedObjects, anchor, error in
                
                if let errorFound = error
                {
                    print("query error: \(errorFound.localizedDescription)")
                    return
                }
                
                guard let samples = samples else
                {
                    return
                }
                
                for sample in samples
                {
                    if let quantitySample = sample as? HKQuantitySample
                    {
                        let heartRate = quantitySample.quantity.doubleValue(for: heartRateUnit)
                        let time = quantitySample.endDate
                        
                        print("\(quantitySample.startDate) — \(time) : \(heartRate)")
                        Database.sharedDatabase.logHeartRate(rate: heartRate, time: time.timeIntervalSinceReferenceDate)
                    }
                }
            }
                      
            self.healthKitStore.execute(query)
            self.query = query
        }
    }
    
    func stop()
    {
        if let query = self.query
        {
            healthKitStore.stop(query)
        }
    }
}
