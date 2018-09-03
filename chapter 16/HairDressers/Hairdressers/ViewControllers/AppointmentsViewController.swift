//
//  AppointmentsViewController.swift
//  HairDressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import UIKit
import CoreData
import Intents

class AppointmentsViewController: UIViewController {
  
  var fetchedResultsController: NSFetchedResultsController<Appointment>?
  var viewContext: NSManagedObjectContext {
    return PersistentHelper.shared.persistentContainer.viewContext
  }
  
  @IBOutlet var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true)]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    try! fetchedResultsController?.performFetch()
    
    fetchedResultsController?.delegate = self
    tableView.dataSource = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    INPreferences.requestSiriAuthorization { status in
      print(status == .authorized)
    }
  }
}

extension AppointmentsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController?.fetchedObjects?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath)
    
    if let appointment = fetchedResultsController?.object(at: indexPath) {
      cell.textLabel?.text = appointment.day!
      cell.detailTextLabel?.text = appointment.hairdresser!
    }
    
    return cell
  }
}

extension AppointmentsViewController: NSFetchedResultsControllerDelegate {
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
