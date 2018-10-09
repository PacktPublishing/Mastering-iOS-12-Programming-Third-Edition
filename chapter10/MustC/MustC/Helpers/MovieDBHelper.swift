import Foundation

struct MovieDBHelper {
  typealias MovieDBCallback = (Int?, Double?) -> Void
  static let apiKey = "d9103bb7a17c9edde4471a317d298d7e"

  enum Endpoint {
    case search
    case movieById(Int64)
    
    var urlString: String {
      let baseUrl = "https://api.themoviedb.org/3/"
      
      switch self {
      case .search:
        var urlString = "\(baseUrl)search/movie/"
        urlString = urlString.appending("?api_key=\(MovieDBHelper.apiKey)")
        return urlString
      case let .movieById(movieId):
        var urlString = "\(baseUrl)movie/\(movieId)"
        urlString = urlString.appending("?api_key=\(MovieDBHelper.apiKey)")
        return urlString
      }
    }
  }
  
  typealias IdAndRating = (id: Int?, rating: Double?)
  typealias DataExtractionStrategy = (Data) -> IdAndRating

  private func fetchRating(fromUrl url: URL?, withExtractionStrategy extractionStrategy: @escaping DataExtractionStrategy, callback: @escaping MovieDBCallback) {
    guard let url = url else {
      callback(nil, nil)
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      var rating: Double? = nil
      var remoteId: Int? = nil
      
      defer {
        callback(remoteId, rating)
      }
      
      guard error == nil
        else { return }
      
      guard let data = data
        else { return }
      
      let extractedData = extractionStrategy(data)
      rating = extractedData.rating
      remoteId = extractedData.id
    }
    
    task.resume()
  }
  
  func fetchRating(forMovie movie: String, callback: @escaping MovieDBCallback) {
    let searchUrl = url(forMovie: movie)
    let extractData: DataExtractionStrategy = { data in
      let decoder = JSONDecoder()
      
      guard let response = try? decoder.decode(MovieDBLookupResponse.self, from: data),
        let movie = response.results.first
        else { return (nil, nil) }
      
      return (movie.id, movie.popularity)
    }
    
    fetchRating(fromUrl: searchUrl, withExtractionStrategy: extractData, callback: callback)
  }

  func fetchRating(forMovieId id: Int64, callback: @escaping MovieDBCallback) {
    let movieUrl = url(forMovieId: id)
    let extractData: DataExtractionStrategy = { data in
      let decoder = JSONDecoder()
      
      guard let movie = try? decoder.decode(MovieDBLookupResponse.MovieDBMovie.self, from: data)
        else { return (nil, nil) }
      
      return (movie.id, movie.popularity)
    }
    
    fetchRating(fromUrl: movieUrl, withExtractionStrategy: extractData, callback: callback)
  }
  
  private func url(forMovie movie: String) -> URL? {
    guard let query = movie.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
      else { return nil }
    
    var urlString = Endpoint.search.urlString
    urlString = urlString.appending("&query=\(query)")
    
    return URL(string: urlString)
  }

  private func url(forMovieId id: Int64) -> URL? {
    let urlString = Endpoint.movieById(id).urlString
    return URL(string: urlString)
  }
}
