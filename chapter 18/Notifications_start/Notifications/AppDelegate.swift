import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let tabBar = window?.rootViewController as? UITabBarController {
      for viewController in tabBar.viewControllers ?? [] {
        if var vc = viewController as? PersistentContainerRequiring {
          vc.persistentContainer = PersistentHelper.persistentContainer
        }
      }
    }

    return true
  }
}

