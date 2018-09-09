import UIKit

class ContactCollectionViewCell: UICollectionViewCell {

  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var contactImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contactImage.layer.cornerRadius = 25
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    contactImage.image = nil
  }
}
