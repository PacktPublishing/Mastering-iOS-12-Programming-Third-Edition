import UIKit

class ContactsCollectionViewLayout: UICollectionViewLayout {
  private let itemSize = CGSize(width: 100, height: 90)
  private let itemSpacing: CGFloat = 10
  
  private var layoutAttributes = [UICollectionViewLayoutAttributes]()
  
  private var numberOfRows = 0
  private var numberOfItems = 0
  private var numberOfColumns = 0
  
  override var collectionViewContentSize: CGSize {
    let width = CGFloat(numberOfColumns) * itemSize.width + CGFloat(numberOfColumns - 1) * itemSpacing
    let height = CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows - 1) * itemSpacing
    
    return CGSize(width: width, height: height)
  }
  
  override func prepare() {
    guard let collectionView = self.collectionView
      else { return }
    
    let availableHeight = Int(collectionView.bounds.height + itemSpacing)
    let itemHeight = Int(itemSize.height + itemSpacing)
    
    numberOfItems = collectionView.numberOfItems(inSection: 0)
    numberOfRows = availableHeight / itemHeight
    numberOfColumns = Int(ceil(CGFloat(numberOfItems) / CGFloat(numberOfRows)))
    
    layoutAttributes.removeAll()
    
    layoutAttributes = (0..<numberOfItems).map { itemIndex in
      let row = itemIndex % numberOfRows
      let column = itemIndex / numberOfRows
      
      var xPosition = column * Int(itemSize.width + itemSpacing)
      if row % 2 == 1 {
        xPosition += Int(itemSize.width / 2)
      }
      
      let yPosition = row * Int(itemSize.height + itemSpacing)
      
      let indexPath = IndexPath(row: itemIndex, section: 0)
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = CGRect(x: CGFloat(xPosition), y: CGFloat(yPosition),
                                width: itemSize.width, height: itemSize.height)
      
      return attributes
    }
  }
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    guard let collectionView = self.collectionView
      else { return true }
    
    let availableHeight = newBounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
    let possibleRows = Int(availableHeight + itemSpacing) / Int(itemSize.height + itemSpacing)

    return possibleRows != numberOfRows
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return layoutAttributes.filter { attributes in
      return attributes.frame.intersects(rect)
    }
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return layoutAttributes[indexPath.row]
  }
}
