/*
 * Stickers source: https://openclipart.org/user-detail/bocian
 */

import Foundation
import Messages

struct OwlStickerFactory {
  static private let stickerNames = [
    "bike", "books", "bowler", "drunk", "ebook",
    "family", "grill", "normal", "notebook", "party",
    "punk", "rose", "santa", "spring"
  ]
  
  static var numberOfStickers: Int { return stickerNames.count }
  
  static func sticker(forIndex index: Int) -> MSSticker {
    let stickerName = stickerNames[index]
    
    guard let stickerPath = Bundle.main.path(forResource: stickerName, ofType: "png")
      else { fatalError("Missing sicker with name: \(stickerName)") }
    let stickerUrl = URL(fileURLWithPath: stickerPath)
    
    guard let sticker = try? MSSticker(contentsOfFileURL: stickerUrl, localizedDescription: "\(stickerName) owl")
      else { fatalError("Failed to retrieve sticker: \(stickerName)") }
    
    return sticker
  }
}
