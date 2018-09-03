//
//  HealthKitHelper.swift
//  Trekker
//
//  Created by Donny Wals on 13/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import Foundation
import HealthKit
import CoreLocation

class HealthKitHelper {
  let healthKitStore = HKHealthStore()
  var workoutBuilder: HKWorkoutRouteBuilder?
  var workoutStartDate: Date?
  
  var isHealthKitAvailable: Bool {
    return HKHealthStore.isHealthDataAvailable()
  }
  
  var hasWorkoutsAccess: Bool {
    return healthKitStore.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
  }
  
  var hasWorkoutRoutesAccess: Bool {
    return healthKitStore.authorizationStatus(for: HKSeriesType.workoutRoute()) == .sharingAuthorized
  }
  
  var canTrackWorkout: Bool {
    return hasWorkoutsAccess && hasWorkoutRoutesAccess
  }
  
  func requestPermissions() {
    guard isHealthKitAvailable
      else { return }

    let objectTypes: Set<HKSampleType> = [HKObjectType.workoutType(), HKSeriesType.workoutRoute()]
    healthKitStore.requestAuthorization(toShare: objectTypes, read: objectTypes) { success, error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
  }
  
  func startWorkout() {
    workoutBuilder = HKWorkoutRouteBuilder(healthStore: healthKitStore, device: nil)
    workoutStartDate = Date()
  }
  
  func appendWorkoutData(_ location: CLLocation) {
    workoutBuilder?.insertRouteData([location]) { success, error in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("Location data added to route")
      }
    }
  }
  
  func endWorkout() {
    guard let builder = workoutBuilder, let startDate = workoutStartDate
      else { return }
    
    let workout = HKWorkout(activityType: .running, start: startDate, end: Date())
    
    healthKitStore.save(workout) { success, error in
      builder.finishRoute(with: workout, metadata: [ : ]) { route, error in
        if let error = error {
          print(error.localizedDescription)
        } else {
          print("route saved: \(route.debugDescription)")
        }
      }
    }
  }
}
