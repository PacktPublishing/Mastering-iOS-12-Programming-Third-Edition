import Foundation
import CoreData

struct PersistentHelper {
  
  static let shared = PersistentHelper()
  let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Hairdressers")
    container.loadPersistentStores { _, error in
      if let error = error {
        print(error.localizedDescription)
      }
    }
    return container
  }()
  
  private init() {}
}
