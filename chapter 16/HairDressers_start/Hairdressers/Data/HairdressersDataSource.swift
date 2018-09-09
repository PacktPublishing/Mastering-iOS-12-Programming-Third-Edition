import Foundation

struct HairdressersDataSource {
  static var hairdressers: [String] = {
    let fileUrl = Bundle.main.url(forResource: "Hairdressers", withExtension: "plist")!
    let data = try! Data(contentsOf: fileUrl)
    let decoder = PropertyListDecoder()
    return try! decoder.decode([String].self, from: data)
  }()
}
