import UIKit
import UserNotifications
import UserNotificationsUI
import CoreData

class NotificationViewController: UIViewController, UNNotificationContentExtension {

  @IBOutlet var reminderTitleLabel: UILabel!
  @IBOutlet var reminderDueDateLabel: UILabel!
  @IBOutlet var reminderStatusLabel: UILabel!

  func didReceive(_ notification: UNNotification) {
    guard let identifier = notification.request.content.userInfo["reminder-uuid"] as? String
      else { return }

    let predicate = NSPredicate(format: "identifier == %@", identifier)
    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.predicate = predicate

    let moc = PersistentHelper.persistentContainer.viewContext
    guard let results = try? moc.fetch(fetchRequest),
      let reminder = results.first
      else { return }

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .medium

    reminderTitleLabel.text = reminder.title
    reminderDueDateLabel.text = dateFormatter.string(from: reminder.dueDate!)
    reminderStatusLabel.text = reminder.isCompleted ? "Done" : "Pending"

    setNotificationForReminder(reminder)
  }

  func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {

    guard let reminder = extractReminderFromResponse(response) else {
      completion(.dismissAndForwardAction)
      return
    }

    if response.actionIdentifier == "complete-reminder" {
      setCompleted(true, forReminder: reminder, completionHandler: completion)
    } else {
      setCompleted(false, forReminder: reminder, completionHandler: completion)
    }

    setNotificationForReminder(reminder)
  }

  func setCompleted(_ completed: Bool, forReminder reminder: Reminder, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {

    reminder.managedObjectContext!.perform {
      reminder.isCompleted = true
      self.reminderStatusLabel.text = reminder.isCompleted ? "Done" : "Pending"

      try! reminder.managedObjectContext!.save()

      completion(.doNotDismiss)
    }
  }

  func setNotificationForReminder(_ reminder: Reminder) {
    let identifier = reminder.isCompleted ? "pending-reminder": "complete-reminder"
    let label = reminder.isCompleted ? "Pending" : "Complete"

    let action = UNNotificationAction(identifier: identifier, title: label, options: [])
    extensionContext?.notificationActions = [action]
  }

  func extractReminderFromResponse(_ response: UNNotificationResponse) -> Reminder? {
    let userInfo = response.notification.request.content.userInfo

    guard let identifier = userInfo["reminder-uuid"] as? String else {
        return nil
    }

    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)

    let moc = PersistentHelper.persistentContainer.viewContext
    guard let results = try? moc.fetch(fetchRequest),
      let reminder = results.first else {
        return nil
    }

    return reminder
  }
}
