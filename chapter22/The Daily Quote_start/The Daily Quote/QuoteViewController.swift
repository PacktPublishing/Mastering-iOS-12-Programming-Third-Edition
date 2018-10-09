import UIKit

class QuoteViewController: UIViewController {

  @IBOutlet var quoteLabel: UILabel!
  @IBOutlet var quoteCreator: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    let quote = Quote.current
    quoteLabel.text = quote.text
    quoteCreator.text = quote.creator
  }
}

