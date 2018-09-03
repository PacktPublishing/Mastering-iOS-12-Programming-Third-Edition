//
//  Contact.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 09/04/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit
import Contacts

class Contact {
  private let contact: CNContact
  var image: UIImage?

  var givenName: String {
    return contact.givenName
  }

  var familyName: String {
    return contact.familyName
  }

  init(contact: CNContact) {
    self.contact = contact
  }

  func fetchImageIfNeeded(completion: @escaping ((UIImage?) -> Void) = { _ in }) {
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
