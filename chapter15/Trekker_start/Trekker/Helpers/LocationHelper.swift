import Foundation
import CoreLocation

class LocationHelper: NSObject {
  let locationManager = CLLocationManager()
  
  private var askPermissionCallback: ((CLAuthorizationStatus) -> Void)?
  private var locationReceivedCallback: ((CLLocation) -> Void)?
  
  var trackedLocations = [CLLocation]()
  
  override init() {
    super.init()
    
    locationManager.delegate = self
    locationManager.allowsBackgroundLocationUpdates = true
  }
  
  func askPermission(_ completion: @escaping (CLAuthorizationStatus) -> Void) {
    let authorizationStatus = CLLocationManager.authorizationStatus()
    if authorizationStatus != .notDetermined {
      completion(authorizationStatus)
    } else {
      askPermissionCallback = completion
      locationManager.requestAlwaysAuthorization()
    }
  }
  
  func beginTrackingLocation(_ locationReceived: @escaping (CLLocation) -> Void) {
    if let location = trackedLocations.last {
      locationReceived(location)
    }
    
    self.locationReceivedCallback = locationReceived
    locationManager.startUpdatingLocation()
  }
  
  func stopTrackingLocation() {
    locationManager.stopUpdatingLocation()
    locationReceivedCallback = nil
  }
}

extension LocationHelper: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    askPermissionCallback?(status)
    askPermissionCallback = nil
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    locationReceivedCallback?(locations.last!)
    trackedLocations += locations
  }
}

