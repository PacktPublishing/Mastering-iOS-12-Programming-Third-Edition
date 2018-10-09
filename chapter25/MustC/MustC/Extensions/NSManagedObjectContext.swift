import CoreData

extension NSManagedObjectContext {
  func persist(block: @escaping () -> Void) {
    perform {
      block()
      
      do {
        try self.save()
      } catch {
        self.rollback()
      }
    }
  }
}
