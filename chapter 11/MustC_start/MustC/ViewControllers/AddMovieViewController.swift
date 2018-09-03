//
//  AddMovieViewController.swift
//  MustC
//
//  Created by Donny Wals on 23/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class AddMovieViewController: UIViewController {
  
  @IBOutlet var movieNameField: UITextField!
  
  var delegate: AddMovieDelegate?
  
  @IBAction func cancelTapped() {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveTapped() {
    delegate?.saveMovie(withName: movieNameField.text ?? "")
    dismiss(animated: true, completion: nil)
  }
  
}
