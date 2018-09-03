//
//  AppointmentShortcutHelper.swift
//  Hairdressers
//
//  Created by Donny Wals on 14/08/2018.
//  Copyright © 2018 Donny Wals. All rights reserved.
//

import Foundation
import Intents

struct AppointmentShortcutHelper {
  static func activityForAppointment(_ appointment: Appointment) -> NSUserActivity {
    let userActivity = NSUserActivity.appointmentActivity()
    let title = "Book an appointment with \(appointment.hairdresser!) for \(appointment.day!)"
    
    userActivity.requiredUserInfoKeys = ["hairdresser", "day"]
    userActivity.userInfo = ["hairdresser": appointment.hairdresser!, "day": appointment.day!]
    userActivity.title = title
    userActivity.isEligibleForPrediction = true
    userActivity.persistentIdentifier = "\(appointment.hairdresser!)-\(appointment.day!)"
    userActivity.suggestedInvocationPhrase = title
    
    return userActivity
  }
  
  static func donateInteractionForAppointment(_ appointment: Appointment) {
    let intent = BookAppointmentIntent()
    intent.hairdresser = appointment.hairdresser
    intent.day = appointment.day
    let title = "Book an appointment with \(appointment.hairdresser!) for \(appointment.day!)"
    intent.suggestedInvocationPhrase = title
    
    let interaction = INInteraction(intent: intent, response: nil)
    interaction.donate { error in
      print(error)
    }
  }
  
  static func storeAppointmentForActivity(_ userActivity: NSUserActivity) {
    guard let userInfo = userActivity.userInfo,
      let hairdresser = userInfo["hairdresser"] as? String,
      let day = userInfo["day"] as? String
      else { return }
    
    let moc = PersistentHelper.shared.persistentContainer.viewContext
    
    moc.persist {
      let appointment = Appointment(context: moc)
      appointment.day = day
      appointment.hairdresser = hairdresser
    }
  }
}
