import CoreData

struct PersistentHelper {
  static let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Notifications")

    container.loadPersistentStores(completionHandler: { (storeDescription, error) in

    })
    return container
  }()
}

