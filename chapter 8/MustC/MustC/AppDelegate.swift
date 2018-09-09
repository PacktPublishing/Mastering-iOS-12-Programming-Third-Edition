import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "MustC")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error {
          fatalError("Unresolved error (error), (error.userInfo)")
        }
      })
      return container
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let navVC = window?.rootViewController as? UINavigationController,
      var initialVC = navVC.viewControllers[0] as? PersistenContainerRequiring {

      initialVC.persistentContainer = persistentContainer
    }

    return true
  }

  func applicationWillTerminate(_ application: UIApplication) {
    persistentContainer.saveContextIfNeeded()
  }
}

