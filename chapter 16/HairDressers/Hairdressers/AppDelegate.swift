//
//  AppDelegate.swift
//  HairDressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import UIKit
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    let hairdressers = NSOrderedSet(array: HairdressersDataSource.hairdressers)
    INVocabulary.shared().setVocabularyStrings(hairdressers, of: .contactName)
    
    return true
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    
    var allowedActivities = [NSUserActivity.identifierForAppointment, "BookAppointmentIntent"]
    
    guard allowedActivities.contains(userActivity.activityType)
      else { return false }
    
    AppointmentShortcutHelper.storeAppointmentForActivity(userActivity)
    return true
  }
}

