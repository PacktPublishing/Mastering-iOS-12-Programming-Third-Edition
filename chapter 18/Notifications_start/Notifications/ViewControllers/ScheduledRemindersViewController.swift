import UIKit
import CoreData

class ScheduledRemindersViewController: UIViewController, PersistentContainerRequiring {
  @IBOutlet var tableView: UITableView!
  var fetchedResultsController: NSFetchedResultsController<Reminder>!
  let dateFormatter = DateFormatter()
  var persistentContainer: NSPersistentContainer!

  override func viewDidLoad() {
    super.viewDidLoad()

    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .medium

    tableView.delegate = self
    tableView.dataSource = self

    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true), NSSortDescriptor(key: "createdAt", ascending: false)]

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self

    try! fetchedResultsController.performFetch()
  }
}

extension ScheduledRemindersViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as? ReminderTableViewCell
      else { fatalError("Failed to dequeue ReminderTableViewCell") }

    let reminder = fetchedResultsController.object(at: indexPath)
    cell.titleLabel.text = reminder.title
    cell.dueDateLabel.text = dateFormatter.string(from: reminder.dueDate!)
    cell.isCompleted = reminder.isCompleted

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let reminder = fetchedResultsController.object(at: indexPath)
    reminder.managedObjectContext?.perform {
      reminder.isCompleted.toggle()
      try! reminder.managedObjectContext?.save()
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ScheduledRemindersViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch type {
    case .insert:
      guard let insertIndex = newIndexPath
        else { return }
      tableView.insertRows(at: [insertIndex], with: .automatic)
    case .delete:
      guard let deleteIndex = indexPath
        else { return }
      tableView.deleteRows(at: [deleteIndex], with: .automatic)
    case .move:
      guard let fromIndex = indexPath,
        let toIndex = newIndexPath
        else { return }
      tableView.moveRow(at: fromIndex, to: toIndex)
    case .update:
      guard let updateIndex = indexPath
        else { return }
      tableView.reloadRows(at: [updateIndex], with: .automatic)
    }
  }
}
