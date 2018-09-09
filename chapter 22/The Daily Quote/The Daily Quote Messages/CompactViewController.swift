import UIKit

class CompactViewController: UIViewController {
  @IBOutlet var quoteLabel: UILabel!
  @IBOutlet var quoteCreator: UILabel!

  var delegate: QuoteSelectionDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let quote = Quote.current
    quoteLabel.text = quote.text
    quoteCreator.text = quote.creator
  }
  
  @IBAction func shareTapped() {
    delegate?.shareQuote(Quote.current)
  }
}
