import CoreData

protocol PersistentContainerRequiring {
  var persistentContainer: NSPersistentContainer! { get set }
}
