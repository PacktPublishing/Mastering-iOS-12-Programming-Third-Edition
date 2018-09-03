import UIKit
import UserNotifications

struct NotificationsHelper {
  let notificationCenter = UNUserNotificationCenter.current()
  
  func requestNotificationPermissions(_ completion: @escaping (Bool) -> ()) {
    notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { permissionGranted, error in
      completion(permissionGranted)
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
  
  func userHasDisabledNotifications(_ completion: @escaping (Bool) -> ()) {
    notificationCenter.getNotificationSettings { settings in
      completion(settings.authorizationStatus == .denied)
    }
  }
  
  func createNotificationContentForReminder(_ reminder: Reminder) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()

    content.title = "Reminder"
    content.body = reminder.title ?? ""
    content.badge = 1

    return content
  }
}
