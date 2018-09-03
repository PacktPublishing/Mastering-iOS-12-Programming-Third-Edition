import UIKit

let collectionViewHeight = 667
let itemHeight = 90
let itemWidth = 100
let itemSpacing = 10
let numberOfItems = 60
let numberOfRows = (collectionViewHeight + itemSpacing) / (itemHeight + itemSpacing)
let numberOfColumns = numberOfItems / numberOfRows

let allFrames: [CGRect] = (0..<numberOfItems).map { itemIndex in
  let row = itemIndex % numberOfRows
  let column = itemIndex / numberOfRows
  
  var xPosition = column * (itemWidth + itemSpacing)
  if row % 2 == 1 {
    xPosition += itemWidth / 2
  }
  
  let yPosition = row * (itemHeight + itemSpacing)
  
  return CGRect(x: xPosition, y: yPosition, width: itemWidth, height: itemHeight)
}

print(allFrames)
