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
