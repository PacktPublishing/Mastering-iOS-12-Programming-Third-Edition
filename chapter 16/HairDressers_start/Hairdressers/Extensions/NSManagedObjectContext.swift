import CoreData

extension NSManagedObjectContext {
  func persist(_ block: @escaping () -> ()) {
    self.perform {
      block()
      
      do {
        try self.save()
      } catch {
        self.rollback()
      }
    }
  }
}
