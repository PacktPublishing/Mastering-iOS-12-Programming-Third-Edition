import Foundation
import CoreData

struct PersistentHelper {
  
  static let shared = PersistentHelper()
  let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Hairdressers")
    
    let containerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.donnywals.hairdressers")!
    let databaseUrl = containerUrl.appendingPathComponent("Hairdressers.sqlite")
    let description = NSPersistentStoreDescription(url: databaseUrl)
    container.persistentStoreDescriptions = [description]
    
    container.loadPersistentStores { _, error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
    return container
  }()
  
  private init() {}
}
