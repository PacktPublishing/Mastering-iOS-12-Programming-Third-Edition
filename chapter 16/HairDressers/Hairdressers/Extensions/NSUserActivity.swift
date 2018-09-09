import Foundation

extension NSUserActivity {
  static var identifierForAppointment: String {
    return "com.donnywals.hairdressers.appointment"
  }
  
  static func appointmentActivity() -> NSUserActivity {
    return NSUserActivity(activityType: identifierForAppointment)
  }
}
