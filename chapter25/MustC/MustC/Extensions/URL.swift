import Foundation

extension URL {
  var queryDict: [String: String]? {
    guard let pairs = query?.components(separatedBy: "&")
      else { return nil }
    
    var dict = [String: String]()
    
    for pair in pairs {
      let components = pair.components(separatedBy: "=")
      dict[components[0]] = components[1]
    }
    
    return dict
  }
}
