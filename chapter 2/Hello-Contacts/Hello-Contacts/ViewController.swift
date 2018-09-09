import UIKit
import Contacts

class ViewController: UIViewController {
  var contacts = [Contact]()

  @IBOutlet var collectionView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.prefetchDataSource = self
    collectionView.delegate = self
    collectionView.collectionViewLayout = ContactsCollectionViewLayout()
    
    let store = CNContactStore()
    let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

    if authorizationStatus == .notDetermined {
      store.requestAccess(for: .contacts) { [weak self] didAuthorize, error in
        if didAuthorize {
          self?.retrieveContacts(from: store)
        }
      }
    } else if authorizationStatus == .authorized  {
      retrieveContacts(from: store)
    }
    
    let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                           action: #selector(self.userDidLongPress(_:)))
    collectionView.addGestureRecognizer(longPressRecognizer)
    
    navigationItem.rightBarButtonItem = editButtonItem
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
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
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
      UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
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
    }
    
    present(confirmationDialog, animated: true, completion: nil)
  }
  
  func retrieveContacts(from store: CNContactStore) {
    let containerId = store.defaultContainerIdentifier()
    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
    let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                       CNContactFamilyNameKey as CNKeyDescriptor,
                       CNContactImageDataAvailableKey as CNKeyDescriptor,
                       CNContactImageDataKey as CNKeyDescriptor]
    
    contacts = try! store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
      .map { Contact(contact: $0) }
    
    DispatchQueue.main.async { [weak self] in
      self?.collectionView.reloadData()
    }
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
    cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
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
    
    UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
      cell.contactImage.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }, completion: { _ in
      UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseIn], animations: {
        cell.contactImage.transform = .identity
      }, completion: nil)
    })
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if isEditing {
      cell.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    } else {
      cell.backgroundColor = .clear
    }
  }
}
