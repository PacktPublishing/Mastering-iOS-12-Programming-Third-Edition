import UIKit
import CoreData

class AddNotificationViewController: UIViewController, PersistentContainerRequiring {
  var persistentContainer: NSPersistentContainer!
  let notificationsHelper = NotificationsHelper()
  
  @IBOutlet var enableNotificationsButton: UIButton!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    notificationsHelper.userHasDisabledNotifications { [weak self] notificationsDisabled in
      DispatchQueue.main.async {
        self?.enableNotificationsButton.isHidden = !notificationsDisabled
      }
    }
  }

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
    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
  }

  func createReminder(_ title: String, withComponents components: DateComponents, inContext moc: NSManagedObjectContext) {
    let reminder = Reminder(context: moc)
    reminder.dueDate = NSCalendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)!
    reminder.title = title
    reminder.isCompleted = false
    reminder.createdAt = Date()
    reminder.identifier = UUID()
    
    DispatchQueue.main.async { [weak self] in
      self?.notificationsHelper.requestNotificationPermissions { result in
        DispatchQueue.main.async {
          self?.enableNotificationsButton.isHidden = result
        }
      }
    }
  }

  @IBAction func drinkWaterNotificationToggled(sender: UISwitch) {
    if sender.isOn {
      notificationsHelper.requestNotificationPermissions { [weak self] result in
        DispatchQueue.main.async {
          self?.enableNotificationsButton.isHidden = result
        }
      }
    }
  }
}
