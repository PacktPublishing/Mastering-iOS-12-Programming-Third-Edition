import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Notifications")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in

    })
    return container
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let tabBar = window?.rootViewController as? UITabBarController {
      for viewController in tabBar.viewControllers ?? [] {
        if var vc = viewController as? PersistentContainerRequiring {
          vc.persistentContainer = persistentContainer
        }
      }
    }

    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UIApplication.shared.registerForRemoteNotifications()
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = String(data: data, encoding: .utf8)
    print("received device token: \(token)")
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Did nit register for remote notifications: \(error.localizedDescription)")
  }
}

