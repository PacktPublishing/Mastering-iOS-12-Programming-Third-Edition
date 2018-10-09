import UIKit

class QuotesTableViewController: UITableViewController {
  var delegate: QuoteSelectionDelegate?
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Quote.numberOfQuotes
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: indexPath)
    let quote = Quote.quote(atIndex: indexPath.row)
    
    cell.textLabel?.text = quote?.text
    cell.detailTextLabel?.text = quote?.creator
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let quote = Quote.quote(atIndex: indexPath.row)
      else { return }
    delegate?.shareQuote(quote)
  }
}
