import IntentsUI

class IntentViewController: UIViewController, INUIHostedViewControlling, INUIHostedViewSiriProviding {
  
  @IBOutlet var recipientsLabel: UILabel!
  @IBOutlet var messageContentLabel: UILabel!
  
  var displaysMessage = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  func configure(with interaction: INInteraction, context: INUIHostedViewContext, completion: ((CGSize) -> Void)) {
    
    guard let messageIntent = interaction.intent as? INSendMessageIntent,
      let recipients = messageIntent.recipients
      else { return }
    
    
    recipientsLabel.text = recipients.map { $0.displayName }.joined(separator: ", ")
    messageContentLabel.text = messageIntent.content
    
    
    let viewWidth = extensionContext?.hostedViewMaximumAllowedSize.width ?? 0
    completion(CGSize(width: viewWidth, height: 100))
  }
}
