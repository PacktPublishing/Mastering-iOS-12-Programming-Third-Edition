import UIKit

class ListViewController: UIViewController {
  let cellIdentitier = "ListTableViewCell"
  
  @IBOutlet var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let collectionVC = segue.destination as? ListCollectionViewController,
      segue.identifier == "ShowCollectionSegue"
      else { return }
    
    collectionVC.delegate = self
  }
}

extension ListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 50
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentitier, for: indexPath)
    
    cell.textLabel?.text = "Item \(indexPath.row)"
    
    return cell
  }
}

extension ListViewController: ListCollectionDelegate {
  func collectionDidChange(viewController: ListCollectionViewController) {
    // empty implementation
  }
}

