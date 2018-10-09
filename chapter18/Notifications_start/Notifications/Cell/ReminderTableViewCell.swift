import UIKit

class ReminderTableViewCell: UITableViewCell {
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var dueDateLabel: UILabel!
  @IBOutlet var completionLabel: UILabel!

  var isCompleted: Bool = false {
    didSet {
      if isCompleted {
        completionLabel.text = "Done"
      } else {
        completionLabel.text = "Pending"
      }
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    isCompleted = false
  }
}
