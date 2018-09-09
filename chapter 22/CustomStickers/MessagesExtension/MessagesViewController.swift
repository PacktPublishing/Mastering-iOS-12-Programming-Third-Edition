import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
  
  var stickerBrowser = MSStickerBrowserViewController(stickerSize: .regular)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    stickerBrowser.willMove(toParent: self)
    addChild(stickerBrowser)
    stickerBrowser.didMove(toParent: self)
    
    view.addSubview(stickerBrowser.view)
    stickerBrowser.stickerBrowserView.dataSource = self
    stickerBrowser.stickerBrowserView.reloadData()
    stickerBrowser.stickerBrowserView.backgroundColor = UIColor.red
  }
}

extension MessagesViewController: MSStickerBrowserViewDataSource {
  func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
    return OwlStickerFactory.sticker(forIndex: index)
  }
  
  func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
    return OwlStickerFactory.numberOfStickers
  }
}
