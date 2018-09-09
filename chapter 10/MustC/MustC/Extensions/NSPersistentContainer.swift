import CoreData

extension NSPersistentContainer {
  func saveContextIfNeeded() {
    if viewContext.hasChanges {
      do {
        try viewContext.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}
