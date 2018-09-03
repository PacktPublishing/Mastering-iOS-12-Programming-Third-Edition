//
//  NavigationDelegate.swift
//  Hello-Contacts
//
//  Created by Donny Wals on 19/07/2018.
//  Copyright © 2018 DonnyWals. All rights reserved.
//

import UIKit

class NavigationDelegate: NSObject {
  let navigationController: UINavigationController
  var interactionController: UIPercentDrivenInteractiveTransition?

  init(withNavigationController navigationController: UINavigationController) {
    self.navigationController = navigationController

    super.init()

    let panRecognizer = UIPanGestureRecognizer(target: self,
                                               action: #selector(handlePan(gestureRecognizer:)))
    navigationController.view.addGestureRecognizer(panRecognizer)
  }

  @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    guard let view = self.navigationController.view
      else { return }

    switch gestureRecognizer.state {
    case .began:
      let location = gestureRecognizer.location(in: view)
      if location.x < view.bounds.midX &&
        navigationController.viewControllers.count > 1 {

        interactionController = UIPercentDrivenInteractiveTransition()
        navigationController.popViewController(animated: true)
      }
      break
    case .changed:
      let panTranslation = gestureRecognizer.translation(in: view)
      let animationProgress = fabs(panTranslation.x / view.bounds.width)
      interactionController?.update(animationProgress)
      break
    default:
      if gestureRecognizer.velocity(in: view).x > 0 {
        interactionController?.finish()
      } else {
        interactionController?.cancel()
      }

      interactionController = nil
    }
  }
}

extension NavigationDelegate: UINavigationControllerDelegate {
  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    if operation == .pop {
      return ContactDetailHideAnimator()
    } else {
      return ContactDetailShowAnimator()
    }
  }

  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactionController
  }
}
