import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {

  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?

  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

    guard let identifier = request.content.userInfo["reminder-uuid"] as? String else {
      contentHandler(request.content)
      return
    }

    let predicate = NSPredicate(format: "identifier == %@", identifier)
    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    fetchRequest.predicate = predicate

    let moc = PersistentHelper.persistentContainer.viewContext
    guard let results = try? moc.fetch(fetchRequest),
      let reminder = results.first else {
        contentHandler(request.content)
        return
    }

    if let bestAttemptContent = bestAttemptContent {
      bestAttemptContent.title = "Reminder"
      bestAttemptContent.body = reminder.title ?? ""
      bestAttemptContent.categoryIdentifier = "reminder"

      contentHandler(bestAttemptContent)
    }
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }

}
