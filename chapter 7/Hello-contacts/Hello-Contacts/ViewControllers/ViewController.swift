import UIKit

class ViewController: UIViewController {
  var contacts = [ContactDisplayable]()

  @IBOutlet var collectionView: UICollectionView!

  var navigationDelegate: NavigationDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.prefetchDataSource = self
    collectionView.delegate = self
    collectionView.collectionViewLayout = ContactsCollectionViewLayout()
    
    let contactFetcher = ContactFetchHelper()
    contactFetcher.fetch { [weak self] contacts in
      self?.contacts = contacts
      self?.collectionView.reloadData()
    }
    
    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(self.userDidLongPress(_:)))
    collectionView.addGestureRecognizer(longPressRecognizer)
    
    navigationItem.rightBarButtonItem = editButtonItem
    
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self, sourceView: collectionView)
    }

    if let navigationController = self.navigationController {
      navigationDelegate = NavigationDelegate(withNavigationController: navigationController)
      navigationController.delegate = navigationDelegate
    }
  }
  
  @objc func userDidLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    let tappedPoint = gestureRecognizer.location(in: collectionView)
    guard let indexPath = collectionView.indexPathForItem(at: tappedPoint),
      let tappedCell = collectionView.cellForItem(at: indexPath)
      else { return }
    
    if isEditing {
      beginReorderingForCell(tappedCell, atIndexPath: indexPath, gestureRecognizer: gestureRecognizer)
    } else {
      deleteContactForCell(tappedCell, atIndexPath: indexPath)
    }
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    for cell in collectionView.visibleCells {
      UIView.animate(withDuration: 0.2, delay: 0, options: [UIView.AnimationOptions.curveEaseOut], animations: {
        if editing {
          cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        } else {
          cell.backgroundColor = .clear
        }
      }, completion: nil)
    }
  }

  func beginReorderingForCell(_ cell: UICollectionViewCell, atIndexPath indexPath: IndexPath, gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      collectionView.beginInteractiveMovementForItem(at: indexPath)
      UIView.animate(withDuration: 0.2, delay: 0, options: [UIView.AnimationOptions.curveEaseOut], animations: {
        cell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
      }, completion: nil)
    case .changed:
      let position = gestureRecognizer.location(in: collectionView)
      collectionView.updateInteractiveMovementTargetPosition(position)
    case .ended:
      collectionView.endInteractiveMovement()
    default:
      collectionView.endInteractiveMovement()
    }
  }

  func deleteContactForCell(_ tappedCell: UICollectionViewCell, atIndexPath indexPath: IndexPath) {
    let confirmationDialog = UIAlertController(title: "Delete contact?", message: "Are you sure you want to delete this contact?", preferredStyle: .actionSheet)
    
    let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] _ in
      self?.contacts.remove(at: indexPath.row)
      self?.collectionView.deleteItems(at: [indexPath])
    })
    
    let cancelAction = UIAlertAction(title: "No", style: .default, handler: nil)
    
    confirmationDialog.addAction(deleteAction)
    confirmationDialog.addAction(cancelAction)
    
    if let popOver = confirmationDialog.popoverPresentationController {
      popOver.sourceView = tappedCell
      
      if let cell = tappedCell as? ContactCollectionViewCell {
        let imageCenter = cell.contactImage.center
        popOver.sourceRect = CGRect(x: imageCenter.x,  y: imageCenter.y,
                                    width: 0,  height: 0)
      }
    }
    
    present(confirmationDialog, animated: true, completion: nil)
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return contacts.count
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
      "ContactCollectionViewCell", for: indexPath) as! ContactCollectionViewCell
    let contact = contacts[indexPath.row]
    cell.nameLabel.text = "\(contact.displayName)"
    contact.fetchImageIfNeeded { image in
      cell.contactImage.image = image
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
  }

  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedContact = contacts.remove(at: sourceIndexPath.row)
    contacts.insert(movedContact, at: destinationIndexPath.row)
  }
}

extension ViewController: UICollectionViewDataSourcePrefetching {
  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let contact = contacts[indexPath.row]
      contact.fetchImageIfNeeded()
    }
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell
      else { return }
    
    let onBounceComplete: ViewEffectAnimatorComplete = { [unowned self] position in
      self.performSegue(withIdentifier: "detailViewSegue", sender: self)
    }
    
    let bounce = BounceAnimationHelper(targetView: cell.contactImage, onComplete: onBounceComplete)
    bounce.startAnimation()
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if isEditing {
      cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    } else {
      cell.backgroundColor = .clear
    }
  }
}

extension ViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let contactDetailVC = segue.destination as? ContactDetailViewController,
      segue.identifier == "detailViewSegue",
      let selectedIndex = collectionView.indexPathsForSelectedItems?.first,
      let contact = contacts[selectedIndex.row] as? Contact {
        contactDetailVC.contact = contact
    }
  }
}

extension ViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    guard let tappedIndexPath = collectionView.indexPathForItem(at: location)
      else { return nil }
    
    let contact = contacts[tappedIndexPath.row]
    
    guard let viewController = storyboard?.instantiateViewController(withIdentifier:"ContactDetailViewController") as? ContactDetailViewController
      else { return nil }
    
    viewController.contact = contact as? Contact
    return viewController
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                         commit viewControllerToCommit: UIViewController) {
    
    navigationController?.show(viewControllerToCommit, sender: self)
  }
}
