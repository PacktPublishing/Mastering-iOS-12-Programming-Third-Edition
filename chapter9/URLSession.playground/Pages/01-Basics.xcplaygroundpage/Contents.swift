import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let url = URL(string: "https://apple.com")!
let task = URLSession.shared.dataTask(with: url) {
  data, response, error in
  print(data)
  print(response)
  print(error)
}

task.resume()

let htmlBodyTask = URLSession.shared.dataTask(with: url) { data, response, error in
  guard let data = data, error == nil
    else { return }
  
  let responseString = String(data: data, encoding: .utf8)
  print(responseString)
}

htmlBodyTask.resume()
