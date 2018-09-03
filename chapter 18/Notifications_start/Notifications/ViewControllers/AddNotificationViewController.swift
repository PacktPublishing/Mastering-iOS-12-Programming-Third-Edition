import UIKit
import CoreData

class AddNotificationViewController: UIViewController, PersistentContainerRequiring {
  var persistentContainer: NSPersistentContainer!
  
  @IBOutlet var enableNotificationsButton: UIButton!

  @IBAction func addBedTimeNotification() {
    persistentContainer.viewContext.perform { [unowned self] in
      var components = DateComponents()
      components.hour = 23

      self.createReminder("Bedtime reminder", withComponents: components, inContext: self.persistentContainer.viewContext)

      try! self.persistentContainer.viewContext.save()
    }
  }

  @IBAction func addLunchTimeNotification() {
    persistentContainer.viewContext.perform { [unowned self] in
      var components = DateComponents()
      components.hour = 12
      components.minute = 30

      self.createReminder("Lunch reminder", withComponents: components, inContext: self.persistentContainer.viewContext)

      try! self.persistentContainer.viewContext.save()
    }
  }
  
  @IBAction func openSettingsTapped() {
    
  }

  func createReminder(_ title: String, withComponents components: DateComponents, inContext moc: NSManagedObjectContext) {
    let reminder = Reminder(context: moc)
    reminder.dueDate = NSCalendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
    reminder.title = title
    reminder.isCompleted = false
    reminder.createdAt = Date()
    reminder.identifier = UUID()
  }

  @IBAction func drinkWaterNotificationToggled(sender: UISwitch) {

  }
}
