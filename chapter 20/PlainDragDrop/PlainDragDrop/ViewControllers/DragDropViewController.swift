import UIKit

class DragDropViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
  @IBOutlet var dropArea: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    let dragInteraction = UIDragInteraction(delegate: self)
    imageView.addInteraction(dragInteraction)

    let dropInteraction = UIDropInteraction(delegate: self)
    dropArea.addInteraction(dropInteraction)
  }

}

extension DragDropViewController: UIDragInteractionDelegate {
  func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
    guard let image = imageView.image
      else { return [] }

    let itemProvider = NSItemProvider(object: image)
    return [UIDragItem(itemProvider: itemProvider)]
  }
}

extension DragDropViewController: UIDropInteractionDelegate {
  func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
    return UIDropProposal(operation: .copy)
  }

  func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
    guard let itemProvider = session.items.first?.itemProvider,
      itemProvider.canLoadObject(ofClass: UIImage.self)
      else { return }

    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] loadedItem, error in
      guard let image = loadedItem as? UIImage
        else { return }

      DispatchQueue.main.async {
        self?.dropArea.image = image
      }
    }
  }
}
