//
//  AddFamilyMemberViewController.swift
//  MustC
//
//  Created by Donny Wals on 23/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class AddFamilyMemberViewController: UIViewController {
  
  @IBOutlet var familyNameField: UITextField!
  
  var delegate: AddFamilyMemberDelegate?
  
  @IBAction func cancelTapped() {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveTapped() {
    delegate?.saveFamilyMember(withName: familyNameField.text ?? "")
    dismiss(animated: true, completion: nil)
  }
}
