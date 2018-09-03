import Foundation

struct Pet {
  var name: String
}

func printName(for pet: Pet) {
  var pet = pet
  print(pet.name)
  pet.name = "Jeff"
}

let dog = Pet(name: "Bingo")
printName(for: dog)
print(dog.name)

struct Car {
  var gasRemaining: Double
  
  mutating func fillGasTank() {
    gasRemaining = 1
  }
}

struct TrafficLight {
  var state: TrafficLightState
  // ...
}

enum TrafficLightState: String {
  case green, yellow, red
}

extension TrafficLight {
  func printState() {
    print(state.rawValue)
  }
}
