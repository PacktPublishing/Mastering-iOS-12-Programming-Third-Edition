import UIKit
import CoreData

class MovieDetailViewController: UIViewController, PersistenContainerRequiring {
  
  @IBOutlet var tableView: UITableView!
  
  var persistentContainer: NSPersistentContainer!
  var movie: Movie?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let center = NotificationCenter.default
    center.addObserver(self,
                       selector: #selector(self.mangedObjectContextDidChange(notification:)),
                       name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                       object: nil)
    
    title = movie?.title
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let movie = self.movie
      else { return }
    
    self.userActivity = IndexingFactory.activity(forMovie: movie)
    self.userActivity?.becomeCurrent()
  }
  
  deinit {
    let center = NotificationCenter.default
    center.removeObserver(self)
  }
}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movie?.familyMembers?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "FamilyMemberCell"),
      let familyMembers = movie?.familyMembers
      else { fatalError("Wrong cell identifier requested") }
    
    let familyMembersArray: Array<FamilyMember> = Array(familyMembers) as! Array<FamilyMember>
    let familyMember = familyMembersArray[indexPath.row]
    cell.textLabel?.text = familyMember.name
    
    return cell
  }
}

extension MovieDetailViewController {
  @objc func mangedObjectContextDidChange(notification: NSNotification) {
    guard let userInfo = notification.userInfo
      else { return }
    
    if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<Movie>,
      let movie = self.movie , updatedObjects.contains(movie) {
      
      tableView.reloadData()
    }
    
    if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<FamilyMember> {
      for object in updatedObjects {
        if let movie = self.movie,
          let movies = object.movies
          , movies.contains(movie) {
          
          tableView.reloadData()
          break
        }
      }
    }
  }
}

