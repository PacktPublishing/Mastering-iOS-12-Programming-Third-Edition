//
//  HairdressersViewController.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import UIKit

class HairdressersViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  var hairdressers = HairdressersDataSource.hairdressers
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let chatVC = segue.destination as? ChatViewController,
      let selectedIndexPath = tableView.indexPathForSelectedRow {

      chatVC.hairdresser = hairdressers[selectedIndexPath.row]
      
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
}

extension HairdressersViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return hairdressers.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HairdresserCell", for: indexPath)

    cell.textLabel?.text = hairdressers[indexPath.row]
    
    return cell
  }
}
