//
//  ContactDisplayable.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 23/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

protocol ContactDisplayable {
  var displayName: String { get }
  var image: UIImage? { get set }
  
  func fetchImageIfNeeded()
  func fetchImageIfNeeded(completion: @escaping ((UIImage?) -> Void))
}
