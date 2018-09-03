//
//  ChatViewController.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {
  var hairdresser: String?
  var fetchedResultsController: NSFetchedResultsController<Message>?
  var viewContext: NSManagedObjectContext {
    return PersistentHelper.shared.persistentContainer.viewContext
  }
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var textField: UITextField!
  @IBOutlet var inputBottomConstraint: NSLayoutConstraint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    
    let request: NSFetchRequest<Message> = Message.fetchRequest()
    request.predicate = NSPredicate(format: "hairdresser == %@", hairdresser!)
    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    
    fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController?.delegate = self
    try! fetchedResultsController?.performFetch()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIApplication.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIApplication.keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      else { return }
    
    let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
    inputBottomConstraint.constant = -keyboardFrame.cgRectValue.height + tabBarHeight
    
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.layoutSubviews()
    }
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      else { return }
    
    inputBottomConstraint.constant = 0
    
    UIView.animate(withDuration: animationDuration) { [weak self] in
      self?.view.layoutSubviews()
    }
  }
  
  @IBAction func saveMessage() {
    viewContext.persist { [unowned self] in
      let message = Message(context: self.viewContext)
      message.content = self.textField.text ?? ""
      message.createdAt = Date()
      message.hairdresser = self.hairdresser ?? ""
    }
  }
}

extension ChatViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController?.fetchedObjects?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTableViewCell", for: indexPath) as! ChatTableViewCell
    
    if let message = fetchedResultsController?.object(at: indexPath) {
      cell.messageLabel.text = message.content
    }
    
    return cell
  }
}

extension ChatViewController: NSFetchedResultsControllerDelegate {
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
