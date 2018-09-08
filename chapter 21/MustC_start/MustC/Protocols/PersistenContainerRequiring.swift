import CoreData

protocol PersistenContainerRequiring {
  var persistentContainer: NSPersistentContainer! { get set }
}
