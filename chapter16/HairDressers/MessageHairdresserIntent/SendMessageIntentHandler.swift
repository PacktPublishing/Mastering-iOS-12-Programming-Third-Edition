import UIKit
import Intents

class SendMessageIntentHandler: NSObject {
}

extension SendMessageIntentHandler: INSendMessageIntentHandling {
  func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
    
    guard let recipients = intent.recipients else {
      completion([.needsValue()])
      return
    }
    
    let results: [INSendMessageRecipientResolutionResult] = recipients.map { person in
      let matches = HairdressersDataSource.hairdressers.filter { hairdresser in
        return hairdresser == person.displayName
      }
      
      switch matches.count {
      case 0: return INSendMessageRecipientResolutionResult.needsValue()
      case 1: return INSendMessageRecipientResolutionResult.success(with: person)
      default: return INSendMessageRecipientResolutionResult.disambiguation(with: [person])
      }
    }
    
    completion(results)
  }
  
  func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
    guard let hairdressers = intent.recipients, let content = intent.content else {
      completion(INSendMessageIntentResponse(code: .failure, userActivity: nil))
      return
    }
    
    let moc = PersistentHelper.shared.persistentContainer.viewContext
    moc.persist {
      for hairdresser in hairdressers {
        let message = Message(context: moc)
        message.createdAt = Date()
        message.hairdresser = hairdresser.displayName
        message.content = content
      }
      
      completion(INSendMessageIntentResponse(code: .success, userActivity: nil))
    }
  }
}
