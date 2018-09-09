import Contacts

struct ContactFetchHelper {
  typealias ContactFetchCallback = ([Contact]) -> Void
  
  let store = CNContactStore()
  
  func fetch(withCallback callback: @escaping
    ContactFetchCallback) {
    if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
      store.requestAccess(for: .contacts, completionHandler:
        {authorized, error in
          if authorized {
            self.retrieve(withCallback: callback)
          }
      })
    } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
      retrieve(withCallback: callback)
    }
  }
  
  private func retrieve(withCallback callback: ContactFetchCallback) {
    let containerId = store.defaultContainerIdentifier()
    
    let keysToFetch =
      [CNContactGivenNameKey as CNKeyDescriptor,
       CNContactFamilyNameKey as CNKeyDescriptor,
       CNContactImageDataKey as CNKeyDescriptor,
       CNContactImageDataAvailableKey as CNKeyDescriptor,
       CNContactEmailAddressesKey as CNKeyDescriptor,
       CNContactPhoneNumbersKey as CNKeyDescriptor,
       CNContactPostalAddressesKey as CNKeyDescriptor]
    
    let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
    
    guard let retrievedContacts = try? store.unifiedContacts(matching:
      predicate, keysToFetch: keysToFetch) else {
        // call back with an empty array if we fail to retrieve contacts
        callback([])
        return
    }
    
    let contacts: [Contact] = retrievedContacts.map { contact in
      return Contact(contact: contact)
    }
    
    callback(contacts)
  }
}

