import UIKit

class ListCollectionViewLayout: UICollectionViewLayout {
  private var gutters: Double = 2
  var numItemsPerRow: Double = 3
  private var screenWidth = Double(UIScreen.main.bounds.width)
  private var thumbRectPlaceholders = [CGRect]()
  
  private var sectionItemAttributes = [[UICollectionViewLayoutAttributes]]()
  private var sectionRects = [CGRect]()
  private var itemHeight: CGFloat = 0
  private var totalHeight: CGFloat = 0
  
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    if newBounds.width != collectionView!.bounds.width {
      return true
    }
    
    return false
  }
  
  override func prepare() {
    super.prepare()
    
    guard let numSections = collectionView?.numberOfSections, numSections != 0
      else { return }
    
    if self.collectionView?.traitCollection.horizontalSizeClass == .regular {
      gutters = 4
      numItemsPerRow = 5
    } else {
      gutters = 2
      numItemsPerRow = 3
    }
    
    screenWidth = Double(collectionView?.frame.width ?? 0)
    itemHeight = 0
    totalHeight = 0
    thumbRectPlaceholders.removeAll()
    sectionItemAttributes.removeAll()
    sectionRects.removeAll()
    
    createSizeLookup()
    
    var itemY: CGFloat = 0
    
    for section in 0..<numSections {
      let numItems = collectionView?.numberOfItems(inSection: section) ?? 0
      var itemAttrs = [UICollectionViewLayoutAttributes]()
      
      for i in 0..<numItems {
        let indexPath = IndexPath(item: i, section: section)
        let currentColumn = i % Int(numItemsPerRow)
        let currentRow = floor(Double(i)/numItemsPerRow)
        if var sizeRect = rectForThumbAtIndex(currentColumn) {
          let gutterOffset: CGFloat = section == 0 && currentRow == 0 ? 0 : 1
          sizeRect.origin.y = itemY+gutterOffset
          sizeRect.size.height = itemHeight
          
          let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
          attrs.frame = sizeRect
          itemAttrs.append(attrs)
          if currentColumn == 0 {
            totalHeight = sizeRect.origin.y + sizeRect.size.height
          }
          if currentColumn == Int(numItemsPerRow)-1 {
            itemY = sizeRect.origin.y + sizeRect.size.height
          }
        }
      }
      if let f = itemAttrs.first, let l = itemAttrs.last {
        let sectionRect = CGRect(x: 0, y: f.frame.origin.y, width: collectionView!.frame.width, height: (l.frame.origin.y-f.frame.origin.y+f.frame.size.height))
        
        sectionRects.append(sectionRect)
      }
      sectionItemAttributes.append(itemAttrs)
    }
  }
  
  override var collectionViewContentSize: CGSize {
    var contentSize = collectionView?.bounds.size
    contentSize?.height = totalHeight
    
    return contentSize!
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    if indexPath.section >= sectionItemAttributes.count {
      return nil
    }
    if indexPath.item >= sectionItemAttributes[indexPath.section].count {
      return nil
    }
    
    return sectionItemAttributes[indexPath.section][indexPath.item]
  }
  
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var attrs = [UICollectionViewLayoutAttributes]()
    
    for (i, sectionRect) in sectionRects.enumerated() {
      if rect.intersects(sectionRect) {
        for attr in sectionItemAttributes[i] {
          if rect.intersects(attr.frame) {
            attrs.append(attr)
          }
        }
      }
    }
    
    return attrs
  }
  
  func createSizeLookup() {
    
    for i in 0..<Int(numItemsPerRow) {
      if i == 0 {
        thumbRectPlaceholders.append(rectForItem(i, pX: 0, pW: 0))
      } else {
        let p = thumbRectPlaceholders[i-1]
        thumbRectPlaceholders.append(rectForItem(i, pX: p.origin.x, pW: p.size.width))
      }
    }
    
    var sizeCounter = [CGFloat: Int]()
    for rect in thumbRectPlaceholders {
      if sizeCounter[rect.size.width] == nil {
        sizeCounter[rect.size.width] = 1
      } else {
        sizeCounter[rect.size.width] = sizeCounter[rect.size.width]! + 1
      }
    }
    
    for (size, count) in sizeCounter {
      if let c = sizeCounter[itemHeight] {
        if c < count {
          itemHeight = size
        }
      } else {
        itemHeight = size
      }
    }
  }
  
  func rectForThumbAtIndex(_ i: Int) -> CGRect? {
    createSizeLookup()
    
    if i > thumbRectPlaceholders.count-1 {
      return nil
    }
    
    return thumbRectPlaceholders[i]
  }
  
  private func squareSize(_ i: Int, pX: CGFloat, pW: CGFloat) -> CGFloat {
    return ceil(CGFloat((screenWidth - Double(pX+pW)) / (numItemsPerRow - Double(i))))
  }
  
  private func rectForItem(_ i: Int, pX: CGFloat, pW: CGFloat) -> CGRect {
    let w = squareSize(i, pX:pX, pW: pW)
    let xPos = pX+pW + CGFloat(i == 0 ? 0 : 1)
    
    return CGRect(x: xPos, y: 0, width: w, height: w)
  }
}
