//
//  ContactTableViewCell.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 06/04/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contactImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contactImage.layer.cornerRadius = 25
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    contactImage.image = nil
  }
}
