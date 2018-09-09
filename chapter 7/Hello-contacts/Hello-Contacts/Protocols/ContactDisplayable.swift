import UIKit

protocol ContactDisplayable {
  var displayName: String { get }
  var image: UIImage? { get set }
  
  func fetchImageIfNeeded()
  func fetchImageIfNeeded(completion: @escaping ((UIImage?) -> Void))
}
