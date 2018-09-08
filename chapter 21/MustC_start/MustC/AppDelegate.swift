import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  lazy var cloudStore: CloudStore = CloudStore(persistentContainer: persistentContainer)
  
  private lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MustC")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error {
        fatalError("Unresolved error (error), (error.userInfo)")
      }
    })
    
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    if let tabBarController = window?.rootViewController as? UITabBarController,
      let viewControllers = tabBarController.viewControllers {
      for viewController in viewControllers {
        if let navVC = viewController as? UINavigationController {
          if var coreDataVC = navVC.viewControllers[0] as? PersistenContainerRequiring {
            coreDataVC.persistentContainer = persistentContainer
          }
          
          if var cloudKitVC = navVC.viewControllers[0] as? CloudStoreRequiring {
            cloudKitVC.cloudStore = cloudStore
          }
        }
      }
    }
    
    cloudStore.subscribeToChangesIfNeeded { [weak self] error in
      DispatchQueue.main.async {
        application.registerForRemoteNotifications()
      }
      
      if error == nil {
        self?.cloudStore.fetchDatabaseChanges { fetchError in
          if let error = fetchError {
            print(error)
          }
        }
      }
    }
    
    return true
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    guard let dict = userInfo as? [String: NSObject] else {
      completionHandler(.failed)
      return
    }
    
    cloudStore.handleNotification(dict) { result in
      completionHandler(result)
    }
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    let managedObjectContext = persistentContainer.viewContext
    guard let allMovies = try? managedObjectContext.fetch(fetchRequest) else {
      completionHandler(.failed)
      return
    }
    
    let queue = DispatchQueue(label: "movieDBQueue")
    let group = DispatchGroup()
    let helper = MovieDBHelper()
    var dataChanged = false
    
    for movie in allMovies {
      queue.async(group: group) {
        group.enter()
        helper.fetchRating(forMovieId: movie.remoteId) { id, popularity in
          guard let popularity = popularity,
            popularity != movie.popularity else {
              group.leave()
              return
          }
          
          dataChanged = true
          
          managedObjectContext.persist {
            movie.popularity = popularity
            group.leave()
          }
        }
      }
    }
    
    group.notify(queue: DispatchQueue.main) {
      if dataChanged {
        completionHandler(.newData)
      } else {
        completionHandler(.noData)
      }
    }
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    persistentContainer.saveContextIfNeeded()
  }
}

