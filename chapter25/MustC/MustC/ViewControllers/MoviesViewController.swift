import UIKit
import CoreData
import CoreSpotlight

class MoviesViewController: UIViewController, AddMovieDelegate, PersistenContainerRequiring, CloudStoreRequiring {

  var persistentContainer: NSPersistentContainer!
  var cloudStore: CloudStore!
  var familyMember: FamilyMember?

  @IBOutlet var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(self.managedObjectContextDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let familyMember = self.familyMember
      else { return }
    
    self.userActivity = IndexingFactory.activity(forFamilyMember: familyMember)
    self.userActivity?.becomeCurrent()
  }

  func saveMovie(withName name: String) {
    guard let familyMember = self.familyMember
      else { return }

    let moc = persistentContainer.viewContext

    moc.persist {
      let movie = Movie.find(byName: name, orCreateIn: moc)
      if movie.title == nil || movie.title?.isEmpty == true {
        movie.title = name
        movie.recordName = UUID().uuidString
      }

      let newFavorites: Set <AnyHashable> = familyMember.movies?.adding(movie) ?? [movie]
      familyMember.movies = NSSet(set: newFavorites)

      let helper = MovieDBHelper()
      helper.fetchRating(forMovie: name) { remoteId, rating in
        guard let rating = rating,
          let remoteId = remoteId
          else { return }

        moc.persist {
          movie.popularity = rating
          movie.remoteId = Int64(remoteId)

          self.cloudStore.storeFamilyMember(familyMember) { _ in
            // no action
          }
        }
      }
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navVC = segue.destination as? UINavigationController,
      let addMovieVC = navVC.viewControllers[0] as? AddMovieViewController {

      addMovieVC.delegate = self
    }
  }
}

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->Int {
    return familyMember?.movies?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell"),
      let movies = familyMember?.movies
      else { fatalError("Wrong cell identifier requested or missing family member") }

    let moviesArray = Array(movies as! Set<Movie>)
    let movie = moviesArray[indexPath.row]
    cell.textLabel?.text = movie.title
    cell.detailTextLabel?.text = "Rating: \(movie.popularity)"

    return cell
  }
}

extension MoviesViewController {
  @objc func managedObjectContextDidChange(notification: NSNotification) {
    guard let userInfo = notification.userInfo
      else { return }

    if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<FamilyMember>,
      let familyMember = self.familyMember,
      updatedObjects.contains(familyMember) {
      
      let item = IndexingFactory.searchableItem(forFamilyMember: familyMember)
      CSSearchableIndex.default().indexSearchableItems([item], completionHandler: nil)
      
      tableView.reloadData()
    }

    if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<Movie> {
      for object in updatedObjects {
        if let familyMember = self.familyMember,
          let familyMembers = object.familyMembers,
          familyMembers.contains(familyMember) {
          
          let item = IndexingFactory.searchableItem(forMovie: object)
          CSSearchableIndex.default().indexSearchableItems([item], completionHandler: nil)
          
          tableView.reloadData()
          break
        }
      }
    }
  }
}
