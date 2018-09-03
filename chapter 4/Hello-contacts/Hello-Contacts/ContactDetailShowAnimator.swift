//
//  ContactDetailShowAnimator.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 19/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class ContactDetailShowAnimator: NSObject {

}

extension ContactDetailShowAnimator: UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toViewController = transitionContext.viewController(forKey: .to),
      let fromViewController = transitionContext.viewController(forKey: .from),
      let overviewViewController = fromViewController as? ViewController,
      let tappedIndex = overviewViewController.collectionView.indexPathsForSelectedItems?.first,
      let tappedCell = overviewViewController.collectionView.cellForItem(at: tappedIndex) as? ContactCollectionViewCell
      else { return }

    let contactImageFrame = tappedCell.contactImage.frame
    let startFrame = overviewViewController.view.convert(contactImageFrame, from: tappedCell)

    toViewController.view.frame = startFrame
    toViewController.view.layer.cornerRadius = startFrame.height / 2

    transitionContext.containerView.addSubview(toViewController.view)

    let animationTiming = UICubicTimingParameters(animationCurve: .easeInOut)

    let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: animationTiming)

    animator.addAnimations {
      toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
      toViewController.view.layer.cornerRadius = 0
    }

    animator.addCompletion { finished in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    animator.startAnimation()
  }
}
