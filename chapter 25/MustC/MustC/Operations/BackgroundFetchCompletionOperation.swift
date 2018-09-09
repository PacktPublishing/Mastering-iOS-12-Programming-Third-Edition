import Foundation
import UIKit

class BackgroundFetchCompletionOperation: Operation {
  override var isAsynchronous: Bool { return true }
  override var isExecuting: Bool { return _isExecuting }
  override var isFinished: Bool { return _isFinished }

  var _isExecuting = false
  var _isFinished = false
  
  let completionHandler: (UIBackgroundFetchResult) -> Void
  
  init(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    self.completionHandler = completionHandler
    
  }
  
  override func start() {
    super.start()
    willChangeValue(forKey: #keyPath(isExecuting))
    _isExecuting = true
    didChangeValue(forKey: #keyPath(isExecuting))
    
    var didLoadNewData = false
    
    for operation in dependencies {
      guard let updateOperation = operation as? UpdateMovieOperation else { continue }
      
      if updateOperation.didLoadNewData {
        didLoadNewData = true
        break
      }
    }
    
    if didLoadNewData {
      completionHandler(.newData)
    } else {
      completionHandler(.noData)
    }
    
    willChangeValue(forKey: #keyPath(isFinished))
    _isFinished = true
    didChangeValue(forKey: #keyPath(isFinished)) }
}
