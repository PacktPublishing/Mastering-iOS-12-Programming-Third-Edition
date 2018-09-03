//
//  NSUserActivity.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import Foundation

extension NSUserActivity {
  static var identifierForAppointment: String {
    return "com.donnywals.hairdressers.appointment"
  }
  
  static func appointmentActivity() -> NSUserActivity {
    return NSUserActivity(activityType: identifierForAppointment)
  }
}
