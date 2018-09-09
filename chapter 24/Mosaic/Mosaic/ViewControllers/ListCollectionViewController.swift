import UIKit

class ListCollectionViewController: UIViewController, UIScrollViewDelegate {
  let cellIdentifier = "ListCollectionViewCell"
  @IBOutlet var collectionView: UICollectionView!
  
  var delegate: ListCollectionDelegate?
  var currentPage: Int = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let detailVC = segue.destination as? DetailViewController,
      segue.identifier == "ShowDetailSegue"
      else { return }
    
    detailVC.delegate = self
  }
}

extension ListCollectionViewController: UICollectionViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentSize.height - (scrollView.contentOffset.y + view.bounds.height) < 100 {
      currentPage += 1
      
      collectionView.reloadData()
    }
  }
}

extension ListCollectionViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return currentPage
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 50
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                        for: indexPath) as? ListCollectionViewCell
      else { fatalError("Wrong cell type was dequeued") }
    
    cell.delegate = self
    
    return cell
  }
}

extension ListCollectionViewController: CollectionItemDelegate {
  func didUpdateFavorite(cell: UICollectionViewCell) {
    // empty implementation
  }
}

extension ListCollectionViewController: DetailViewControllerDelegate {
  func detailViewUpdated() {
    // empty implementation
  }
}

