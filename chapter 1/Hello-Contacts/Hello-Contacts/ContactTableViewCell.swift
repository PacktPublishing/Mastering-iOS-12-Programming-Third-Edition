//
//  ContactTableViewCell.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 06/04/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contactImage: UIImageView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    contactImage.image = nil
  }
}
