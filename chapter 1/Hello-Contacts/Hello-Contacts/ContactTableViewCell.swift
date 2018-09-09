import UIKit

class ContactTableViewCell: UITableViewCell {

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contactImage: UIImageView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    contactImage.image = nil
  }
}
