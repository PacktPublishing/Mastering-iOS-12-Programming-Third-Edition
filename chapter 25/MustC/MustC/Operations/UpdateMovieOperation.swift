import Foundation

class UpdateMovieOperation: Operation {
  override var isAsynchronous: Bool { return true }
  override var isExecuting: Bool { return _isExecuting }
  override var isFinished: Bool { return _isFinished }
  
  private var _isExecuting = false
  private var _isFinished = false
  var didLoadNewData = false
  
  let movie: Movie
  
  init(movie: Movie) {
    self.movie = movie
  }
  
  override func start() {
    super.start()
    
    willChangeValue(forKey: #keyPath(isExecuting))
    _isExecuting = true
    didChangeValue(forKey: #keyPath(isExecuting))
    
    let helper = MovieDBHelper()
    helper.fetchRating(forMovieId: movie.remoteId) { [weak self] id,
      popularity in
      defer {
        self?.finish()
      }
      
      guard let popularity = popularity,
        let movie = self?.movie,
        popularity != movie.popularity
        else { return }
      
      self?.didLoadNewData = true
      
      movie.managedObjectContext?.persist {
        movie.popularity = popularity
      }
    }
  }
  
  func finish() {
    willChangeValue(forKey: #keyPath(isFinished))
    _isFinished = true
    didChangeValue(forKey: #keyPath(isFinished))
  }
}
