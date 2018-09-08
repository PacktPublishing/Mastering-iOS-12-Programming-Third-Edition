import UIKit
import CoreData
import CloudKit
import CoreSpotlight

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
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
    if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, userActivity.activityType == CSSearchableItemActionType {
      
      return handleCoreSpotlightActivity(withIdentifier: identifier)
    }
    
    guard let tabBar = window?.rootViewController as? UITabBarController
      else { return false }
    
    let tabIndex: Int?
    if userActivity.title == "Family Members" {
      tabIndex = 0
    } else if userActivity.title == "Movies" {
      tabIndex = 1
    } else {
      tabIndex = nil
    }
    
    guard let index = tabIndex
      else { return false }
    
    guard let navVC = tabBar.viewControllers?[index] as? UINavigationController
      else { return false }
    
    navVC.popToRootViewController(animated: false)
    tabBar.selectedIndex = index
    
    return true
  }

  func handleCoreSpotlightActivity(withIdentifier identifier: String) -> Bool {
    guard let url = URL(string: identifier),
      let objectID = persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url),
      let object = try? persistentContainer.viewContext.existingObject(with: objectID)
      else { return false }
    
    if let movie = object as? Movie {
      return handleOpenMovieDetail(withName: movie.title!)
    }
    
    if let familyMember = object as? FamilyMember {
      return handleOpenFamilyMemberDetail(withName: familyMember.name!)
    }
    return false
  }
  
  func application(_ app: UIApplication, open URL: URL, options:
    [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    let pathComponents = URL.pathComponents
    guard pathComponents.count == 3
      else { return false }
    
    switch(pathComponents[1], pathComponents[2]) {
    case ("familymember", let name):
      return handleOpenFamilyMemberDetail(withName: name)
    case ("movie", let name):
      return handleOpenMovieDetail(withName: name)
    default:
      return false
    }
  }
  
  func handleOpenMovieDetail(withName name: String) -> Bool {
    guard let tabBar = window?.rootViewController as? UITabBarController,
      let navVC = tabBar.viewControllers?[1] as? UINavigationController
      else { return false }
    
    navVC.popToRootViewController(animated: false)
    tabBar.selectedIndex = 1
    
    guard let viewController = navVC.viewControllers[0] as? MoviesListViewController,
      let storyboard = viewController.storyboard
      else { return false }
    
    guard let movieDetailViewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController,
      let movie = Movie.find(byName: name, inContext: persistentContainer.viewContext)
      else { return false }
    
    movieDetailViewController.movie = movie
    movieDetailViewController.persistentContainer = persistentContainer
    
    navVC.pushViewController(movieDetailViewController, animated: true)
    
    return true
  }
  
  func handleOpenFamilyMemberDetail(withName name: String) -> Bool {
    guard let tabBar = window?.rootViewController as? UITabBarController,
      let navVC = tabBar.viewControllers?[0] as? UINavigationController
      else { return false }
    
    navVC.popToRootViewController(animated: false)
    tabBar.selectedIndex = 0
    
    guard let viewController = navVC.viewControllers[0] as? FamilyMembersViewController,
      let storyboard = viewController.storyboard
      else { return false }
    
    guard let familyMemberDetailViewController = storyboard.instantiateViewController(withIdentifier: "MoviesViewController") as? MoviesViewController,
      let familyMember = FamilyMember.find(byName: name, inContext: persistentContainer.viewContext)
      else { return false }
    
    familyMemberDetailViewController.familyMember = familyMember
    familyMemberDetailViewController.persistentContainer = persistentContainer
    
    navVC.pushViewController(familyMemberDetailViewController, animated: true)
    
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

