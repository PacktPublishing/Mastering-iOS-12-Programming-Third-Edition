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
    
    application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum) 

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

