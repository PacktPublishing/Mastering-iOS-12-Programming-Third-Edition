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

  }
  
  func startWorkout() {

  }
  
  func appendWorkoutData(_ location: CLLocation) {

  }
  
  func endWorkout() {

  }
}
