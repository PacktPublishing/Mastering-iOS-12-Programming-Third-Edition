import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  lazy var cloudStore = CloudStore(persistentContainer: persistentContainer)
  
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
    
    if let tabVC = window?.rootViewController as? UITabBarController, let viewControllers = tabVC.viewControllers {
      for child in viewControllers {
        if let navVC = child as? UINavigationController {
          if var coreDataVC = navVC.viewControllers[0] as? PersistenContainerRequiring {
            coreDataVC.persistentContainer = persistentContainer
          } else if var cloudKitVC = navVC.viewControllers[0] as? CloudStoreRequiring {
            cloudKitVC.cloudStore = cloudStore
          }
        }
      }
    }

    return true
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

