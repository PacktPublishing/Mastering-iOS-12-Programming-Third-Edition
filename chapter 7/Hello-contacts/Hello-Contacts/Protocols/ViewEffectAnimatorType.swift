//
//  ViewEffectAnimatorType.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 23/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

typealias ViewEffectAnimatorComplete = (UIViewAnimatingPosition) -> Void

protocol ViewEffectAnimatorType {
  
  var animator: UIViewPropertyAnimator { get }
  
  init(targetView: UIView, onComplete: @escaping ViewEffectAnimatorComplete)
  init(targetView: UIView, onComplete: @escaping ViewEffectAnimatorComplete, duration: TimeInterval)
  
  func startAnimation()
}

extension ViewEffectAnimatorType {
  func startAnimation() {
    animator.startAnimation()
  }
} 
