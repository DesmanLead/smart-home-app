//
//  HeartRateMonitor.swift
//  SmartHome
//
//  Created by Artem Kirienko on 13.09.16.
//  Copyright © 2016 Desman. All rights reserved.
//

import Foundation
import HealthKit

class HeartRateMonitor {
    static let sharedMonitor = HeartRateMonitor()
    
    private let healthKitStore = HKHealthStore()
    private var query: HKQuery?
    
    func start() {
        let heartRateType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
        let heartRateUnit = HKUnit(fromString: "count/min")
        let healthKitTypes: Set = [ heartRateType ]

        healthKitStore.requestAuthorizationToShareTypes(nil, readTypes: healthKitTypes) { _, _ in
            let queryPredicate  = HKQuery.predicateForSamplesWithStartDate(NSDate().dateByAddingTimeInterval(-600), endDate: nil, options: .None)

            let query: HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: heartRateType,
                                                                     predicate: queryPredicate,
                                                                     anchor: nil,
                                                                     limit: HKObjectQueryNoLimit) {
                query, samples, deletedObjects, anchor, error in

                if let errorFound = error {
                    print("query error: \(errorFound.localizedDescription)")
                    return
                }

                guard let samples = samples else {
                    return
                }

                for sample in samples {
                    if let quantitySample = sample as? HKQuantitySample {
                        let heartRate = quantitySample.quantity.doubleValueForUnit(heartRateUnit)
                        let time = quantitySample.endDate
                        
                        print("\(quantitySample.startDate) — \(time) : \(heartRate)")
                        Database.sharedDatabase.logHeartRate(heartRate, time: time.timeIntervalSinceReferenceDate)
                    }
                }
            }
            
            query.updateHandler = {
                query, samples, deletedObjects, anchor, error in
                
                if let errorFound = error {
                    print("query error: \(errorFound.localizedDescription)")
                    return
                }
                
                guard let samples = samples else {
                    return
                }
                
                for sample in samples {
                    if let quantitySample = sample as? HKQuantitySample {
                        let heartRate = quantitySample.quantity.doubleValueForUnit(heartRateUnit)
                        let time = quantitySample.endDate
                        
                        print("\(quantitySample.startDate) — \(time) : \(heartRate)")
                        Database.sharedDatabase.logHeartRate(heartRate, time: time.timeIntervalSinceReferenceDate)
                    }
                }
            }
                      
            self.healthKitStore.executeQuery(query)
            self.query = query
        }
    }
    
    func stop() {
        if let query = self.query {
            healthKitStore.stopQuery(query)
        }
    }
}