import UIKit
import AVKit

class VideoViewController: UIViewController {
  let playerController = AVPlayerViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let url = Bundle.main.url(forResource: "samplevideo", withExtension: "mp4")!
    playerController.player = AVPlayer(url: url)
    
    addChild(playerController)
    playerController.didMove(toParent: self)
    
    view.addSubview(playerController.view)
    
    let playerView = playerController.view!
    playerView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      playerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
      playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 9/16),
      playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
  }
}
