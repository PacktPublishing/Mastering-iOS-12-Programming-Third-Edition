import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    if let tabBar = window?.rootViewController as? UITabBarController {
      for viewController in tabBar.viewControllers ?? [] {
        if var vc = viewController as? PersistentContainerRequiring {
          vc.persistentContainer = PersistentHelper.persistentContainer
        }
      }
    }

    UNUserNotificationCenter.current().delegate = self

    let completeAction = UNNotificationAction(identifier: "complete-reminder", title: "Complete", options: [])
    let summaryFormat = NSString.localizedUserNotificationString(forKey: "REMINDER_SUMMARY", arguments: nil)
    let reminderCategory = UNNotificationCategory(identifier: "reminder", actions: [completeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nil, categorySummaryFormat: summaryFormat, options: [])

    UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])

    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UIApplication.shared.registerForRemoteNotifications()
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("received device token: \(deviceToken)")
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Did not register for remote notifications: \(error.localizedDescription)")
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

    let userInfo = response.notification.request.content.userInfo

    guard response.actionIdentifier == "complete-reminder",
      let identifier = userInfo["reminder-uuid"] as? String else {
        completionHandler()
        return
    }

    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

    let moc = PersistentHelper.persistentContainer.viewContext
    guard let results = try? moc.fetch(fetchRequest),
      let reminder = results.first else {
        completionHandler()
        return
    }

    moc.perform {
      reminder.isCompleted = true
      try? moc.save()

      completionHandler()
    }
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
}
