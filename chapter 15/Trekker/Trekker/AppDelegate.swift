import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let healthKitHelper = HealthKitHelper()
  let locationHelper = LocationHelper()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    if var healthKitVC = window?.rootViewController as? HealthKitRequiring {
      healthKitVC.healthKitHelper = healthKitHelper
    }
    
    if var locationVC = window?.rootViewController as? LocationRequiring {
      locationVC.locationHelper = locationHelper
    }
    
    return true
  }
}

