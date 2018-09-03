//
//  ViewController.swift
//  Trekker
//
//  Created by Donny Wals on 13/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, HealthKitRequiring, LocationRequiring {
  
  var healthKitHelper: HealthKitHelper!
  var locationHelper: LocationHelper!
  var hasActiveWorkout = false
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var workoutButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    healthKitHelper.requestPermissions()
    locationHelper.askPermission { _ in }
  }

  @IBAction func toggleWorkout() {
    guard healthKitHelper.canTrackWorkout
      else { return }
    
    if hasActiveWorkout {
      locationHelper.stopTrackingLocation()
      healthKitHelper.endWorkout()

      workoutButton.setTitle("Start a workout", for: .normal)
    } else {
      healthKitHelper.startWorkout()
      locationHelper.beginTrackingLocation { [weak self] location in

      }

      workoutButton.setTitle("Stop workout", for: .normal)
    }
    
    hasActiveWorkout = !hasActiveWorkout
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locationHelper.trackedLocations.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
    
    let location = locationHelper.trackedLocations[indexPath.row]
    cell.textLabel?.text = "\(location.coordinate.latitude) / \(location.coordinate.longitude)"
    
    return cell
  }
}
