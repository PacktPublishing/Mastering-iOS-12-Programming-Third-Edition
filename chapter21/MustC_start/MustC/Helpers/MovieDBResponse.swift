import Foundation

struct MovieDBLookupResponse: Codable {
  
  struct MovieDBMovie: Codable {
    let popularity: Double?
    let id: Int?
  }
  
  let results: [MovieDBMovie]
}
