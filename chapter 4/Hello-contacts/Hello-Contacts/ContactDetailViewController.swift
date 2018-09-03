import UIKit

class ContactDetailViewController: UIViewController {
  
  @IBOutlet var scrollViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet var contactImage: UIImageView!
  @IBOutlet var contactNameLabel: UILabel!
  @IBOutlet var contactPhoneLabel: UILabel!
  @IBOutlet var contactEmailLabel: UILabel!
  @IBOutlet var contactAddressLabel: UILabel!
  @IBOutlet var drawer: UIView!
  
  var isDrawerOpen = false
  var drawerPanStart: CGFloat = 0
  var animator: UIViewPropertyAnimator?
  
  var compactWidthConstraint: NSLayoutConstraint!
  var compactHeightConstraint: NSLayoutConstraint!
  var regularWidthConstraint: NSLayoutConstraint!
  var regularHeightConstraint: NSLayoutConstraint!
  
  var contact: Contact?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let contact = self.contact {
      contact.fetchImageIfNeeded { [weak self] image in
        self?.contactImage.image = image
      }
      
      contactNameLabel.text = "\(contact.givenName) \(contact.familyName)"
      contactPhoneLabel.text = contact.phoneNumber
      contactEmailLabel.text = contact.emailAddress
      contactAddressLabel.text = contact.address
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear),
                                           name: UIApplication.keyboardWillShowNotification,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                           name: UIApplication.keyboardWillHideNotification,
                                           object: nil)
    
    let views: [String: Any] = ["contactImage": contactImage, "contactNameLabel": contactNameLabel]
    
    var allConstraints = [NSLayoutConstraint]()
    
    compactWidthConstraint = contactImage.widthAnchor.constraint(equalToConstant: 60)
    compactHeightConstraint = contactImage.heightAnchor.constraint(equalToConstant: 60)
    
    regularWidthConstraint = contactImage.widthAnchor.constraint(equalToConstant: 120)
    regularHeightConstraint = contactImage.heightAnchor.constraint(equalToConstant: 120)
    
    let verticalPositioningConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-[contactImage]-[contactNameLabel]",
      options: [.alignAllCenterX], metrics: nil, views: views)
    
    allConstraints += verticalPositioningConstraints
    
    let centerXConstraint = contactImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    
    allConstraints.append(centerXConstraint)
    if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
      allConstraints.append(regularWidthConstraint)
      allConstraints.append(regularHeightConstraint)
    } else {
      allConstraints.append(compactWidthConstraint)
      allConstraints.append(compactHeightConstraint)
    }
    
    NSLayoutConstraint.activate(allConstraints)
    
    let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanOnDrawer(recognizer:)))
    drawer.addGestureRecognizer(panRecognizer)

    view.clipsToBounds = true
  }
  
  @objc func keyboardWillAppear(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      else { return }
    
    scrollViewBottomConstraint.constant = keyboardFrame.cgRectValue.size.height
    UIView.animate(withDuration: TimeInterval(animationDuration), animations: { [weak self ] in
      self?.view.layoutIfNeeded()
    })
  }
  
  @objc func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
      let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
      else { return }
    
    scrollViewBottomConstraint.constant = 0
    UIView.animate(withDuration: TimeInterval(animationDuration), animations: { [weak self ] in
      self?.view.layoutIfNeeded()
    })
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    guard let previousTraitCollection = previousTraitCollection,
      (previousTraitCollection.horizontalSizeClass != traitCollection.horizontalSizeClass ||
        previousTraitCollection.verticalSizeClass != traitCollection.verticalSizeClass)
      else { return}
    
    if traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular {
      NSLayoutConstraint.deactivate([compactHeightConstraint, compactWidthConstraint])
      NSLayoutConstraint.activate([regularHeightConstraint, regularWidthConstraint])
    } else {
      NSLayoutConstraint.deactivate([regularHeightConstraint, regularWidthConstraint])
      NSLayoutConstraint.activate([compactHeightConstraint, compactWidthConstraint])
    }
  }
}

extension ContactDetailViewController {
  func setUpAnimation() {
    guard animator == nil || animator?.isRunning == false
      else { return }
    
    let spring: UISpringTimingParameters
    if self.isDrawerOpen {
      spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: 10))
    } else {
      spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: -10))
    }
    
    animator = UIViewPropertyAnimator(duration: 1, timingParameters: spring)
    
    animator?.addAnimations { [unowned self] in
      if self.isDrawerOpen {
        self.drawer.transform = CGAffineTransform.identity
      } else {
        self.drawer.transform = CGAffineTransform(translationX: 0, y: -305)
      }
    }
    
    animator?.addCompletion { [unowned self] _ in
      self.animator = nil
      self.isDrawerOpen = !(self.drawer.transform == CGAffineTransform.identity)
    }
  }
  
  @IBAction func toggleDrawerTapped() {
    setUpAnimation()
    animator?.startAnimation()
  }
  
  @objc func didPanOnDrawer(recognizer: UIPanGestureRecognizer) {
    switch recognizer.state {
    case .began:
      setUpAnimation()
      animator?.pauseAnimation()
      drawerPanStart = animator?.fractionComplete ?? 0
    case .changed:
      if self.isDrawerOpen {
        animator?.fractionComplete = (recognizer.translation(in: drawer).y / 305) + drawerPanStart
      } else {
        animator?.fractionComplete = (recognizer.translation(in: drawer).y / -305) + drawerPanStart
      }
    default:
      drawerPanStart = 0
      let currentVelocity = recognizer.velocity(in: drawer)
      let spring = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: CGVector(dx: 0, dy: currentVelocity.y))
      
      animator?.continueAnimation(withTimingParameters: spring, durationFactor: 0)
      let isSwipingDown = currentVelocity.y > 0
      if isSwipingDown == !isDrawerOpen {
        animator?.isReversed = true
      }
    }
  }
}
