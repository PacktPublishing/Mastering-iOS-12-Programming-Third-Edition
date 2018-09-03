//
//  ViewController.swift
//  Cradle
//
//  Created by Donny Wals on 15/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var square1: UIView!
  @IBOutlet var square2: UIView!
  @IBOutlet var square3: UIView!
  
  var animator: UIDynamicAnimator!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let squares: [UIDynamicItem] = [square1, square2, square3]
    animator = UIDynamicAnimator(referenceView: view)
    let gravity = UIGravityBehavior(items: squares)
    animator.addBehavior(gravity)
    
    var nextAnchorX = 250

    for square in squares {
      let anchorPoint = CGPoint(x: nextAnchorX, y: 0)
      nextAnchorX -= 30
      let attachment = UIAttachmentBehavior(item: square,
                                            attachedToAnchor: anchorPoint)
      attachment.damping = 0.7
      animator.addBehavior(attachment)
      
      let dynamicBehavior = UIDynamicItemBehavior()
      dynamicBehavior.addItem(square)
      dynamicBehavior.density = CGFloat(arc4random_uniform(3) + 1)
      dynamicBehavior.elasticity = 0.8
      animator.addBehavior(dynamicBehavior)  
    }
    
    let collisions = UICollisionBehavior(items: squares)
    animator.addBehavior(collisions)
  }


}

