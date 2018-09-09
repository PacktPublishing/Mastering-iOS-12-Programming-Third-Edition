import UIKit
import CoreData

class MoviesListViewController: UIViewController, PersistenContainerRequiring {
  
  @IBOutlet var tableView: UITableView!
  
  var persistentContainer: NSPersistentContainer!
  var fetchedResultsController: NSFetchedResultsController<Movie>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let moc = persistentContainer.viewContext
    
    let request = NSFetchRequest<Movie>(entityName: "Movie")
    request.sortDescriptors = []
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                          managedObjectContext: moc,
                                                          sectionNameKeyPath: nil,
                                                          cacheName: nil)
    
    fetchedResultsController?.delegate = self
    
    do {
      try fetchedResultsController?.performFetch()
    } catch {
      print("fetch request failed")
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let userActivity = NSUserActivity(activityType: "com.familymovies.openTab")
    userActivity.title = "Movies"
    userActivity.isEligibleForSearch = true
    userActivity.isEligibleForPublicIndexing = true
    self.userActivity = userActivity
    self.userActivity?.becomeCurrent()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let selectedIndex = tableView.indexPathForSelectedRow
      else { return }
    
    tableView.deselectRow(at: selectedIndex, animated: true)
    
    if let movieVC = segue.destination as? MovieDetailViewController,
      let movie = fetchedResultsController?.object(at: selectedIndex) {
      movieVC.persistentContainer = persistentContainer
      movieVC.movie = movie
    }
  }
  
}
extension MoviesListViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController?.fetchedObjects?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell")
      else { fatalError("Wrong cell identifier requested") }
    
    guard let movie = fetchedResultsController?.object(at: indexPath)
      else { return cell }
    
    cell.textLabel?.text = movie.title
    cell.detailTextLabel?.text = "Rating: \(movie.popularity)"
    
    return cell
  }
}

extension MoviesListViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    
    switch type {
    case .insert:
      guard let insertIndex = newIndexPath
        else { return }
      tableView.insertRows(at: [insertIndex],
                           with: .automatic)
    case .delete:
      guard let deleteIndex = indexPath
        else { return }
      tableView.deleteRows(at: [deleteIndex],
                           with: .automatic)
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


