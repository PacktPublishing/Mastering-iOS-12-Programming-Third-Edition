//
//  Contact.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 09/04/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit
import Contacts

class Contact: ContactDisplayable {
  private let contact: CNContact
  var image: UIImage?

  var givenName: String {
    return contact.givenName
  }

  var familyName: String {
    return contact.familyName
  }
  
  var displayName: String {
    return "\(givenName) \(familyName)"
  }
  
  var emailAddress: String {
    return String(contact.emailAddresses.first?.value ?? "--")
  }

  var phoneNumber: String {
    return contact.phoneNumbers.first?.value.stringValue ?? "--"
  }

  var address: String {
    let street = contact.postalAddresses.first?.value.street ?? "--"
    let city = contact.postalAddresses.first?.value.city ?? "--"

    return "\(street) \(city)"
  }

  init(contact: CNContact) {
    self.contact = contact
  }
  
  func fetchImageIfNeeded() {
    fetchImageIfNeeded(completion: { _ in })
  }

  func fetchImageIfNeeded(completion: @escaping ((UIImage?) -> Void)) {
    guard contact.imageDataAvailable == true, let imageData = contact.imageData else {
      completion(nil)
      return
    }

    if let image = self.image {
      completion(image)
      return
    }

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.image = UIImage(data: imageData)
      DispatchQueue.main.async {
        completion(self?.image)
      }
    }
  }
}
