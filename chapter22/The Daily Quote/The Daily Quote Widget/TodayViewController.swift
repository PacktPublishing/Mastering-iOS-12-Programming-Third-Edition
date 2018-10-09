import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

  @IBOutlet var quoteLabel: UILabel!
  @IBOutlet var quoteCreator: UILabel! 

  override func viewDidLoad() {
    super.viewDidLoad()

    updateWidget()
    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
  }

  func updateWidget() {
    let quote = Quote.current
    quoteLabel.text = quote.text
    quoteCreator.text = quote.creator
  }

  func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
    let currentText = quoteLabel.text
    updateWidget()
    let newText = quoteLabel.text

    if currentText == newText {
      completionHandler(NCUpdateResult.noData)
    } else {
      completionHandler(NCUpdateResult.newData)
    }
  } 

  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {

    if activeDisplayMode == .compact {
      preferredContentSize = maxSize
    } else {
      preferredContentSize = CGSize(width: maxSize.width, height: 200)
    }
  }
}
