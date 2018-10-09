import Intents

class IntentHandler: INExtension, BookAppointmentIntentHandling {
  
  override func handler(for intent: INIntent) -> Any {
    return self
  }
  
  func handle(intent: BookAppointmentIntent, completion: @escaping (BookAppointmentIntentResponse) -> Void) {
    guard let hairdresser = intent.hairdresser, let day = intent.day else {
      completion(BookAppointmentIntentResponse(code: .failure, userActivity: nil))
      return
    }
    
    let moc = PersistentHelper.shared.persistentContainer.viewContext
    
    moc.persist {
      let appointment = Appointment(context: moc)
      appointment.day = day
      appointment.hairdresser = hairdresser
      
      let response = BookAppointmentIntentResponse(code: .success, userActivity: nil)
      response.hairdresser = hairdresser
      completion(response)
    }
  }
}
