import CloudKit
import CoreData

class CloudStore {
  let persistentContainer: NSPersistentContainer

  private var privateDatabase: CKDatabase {
    return CKContainer.default().privateCloudDatabase
  }
  
  init(persistentContainer: NSPersistentContainer) {
    self.persistentContainer = persistentContainer
  }
}
