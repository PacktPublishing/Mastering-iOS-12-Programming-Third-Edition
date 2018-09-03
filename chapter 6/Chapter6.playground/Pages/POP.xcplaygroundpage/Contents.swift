protocol PetType {
  var name: String { get }
  var age: Int { get set }
  
  func sleep()
  
  static var latinName: String { get }
}

struct Cat: PetType {
  let name: String
  var age: Int
  
  static let latinName: String = "Felis catus"
  
  func sleep() {
    print("Cat: ZzzZZ")
  }
}

struct Dog: PetType {
  let name: String
  var age: Int
  
  static let latinName: String = "Canis familiaris"
  
  func sleep() {
    print("Dog: ZzzZZ")
  }
}

func nap(pet: PetType) {
  pet.sleep()
}

protocol Domesticatable {
  var homeAddress: String? { get }
  
  func printHomeAddress()
}

func printHomeAddress(animal: Domesticatable) {
  if let address = animal.homeAddress {
    print(address)
  }
}

protocol HerbivoreType {
  var favoritePlant: String { get }
}

protocol CarnivoreType {
  var favoriteMeat: String { get }
}

protocol OmnivoreType: HerbivoreType, CarnivoreType {}

func printFavoriteMeat(forAnimal animal: CarnivoreType) {
  print(animal.favoriteMeat)
}

func printFavoritePlant(forAnimal animal: HerbivoreType) {
  print(animal.favoritePlant)
}

extension Domesticatable {
  func printHomeAddress() {
    if let address = homeAddress {
      print(address)
    }
  }
}

protocol Bird {}
protocol FlyingType {}

// let myPidgeon = Pigeon(favoriteMeat: "Insects", favoritePlant: "Seeds", homeAddress: "Leidse plein 12, Amsterdam")
// myPidgeon.printHomeAddress() // "Leidse plein 12, Amsterdam"

struct Pigeon: Bird, FlyingType, OmnivoreType, Domesticatable {
  let favoriteMeat: String
  let favoritePlant: String
  let homeAddress: String?
  
  func printHomeAddress() {
    if let address = homeAddress {
      print("address: \(address.uppercased())")
    }
  }
}

let myPigeon = Pigeon(favoriteMeat: "Insects", favoritePlant: "Seeds", homeAddress: "Leidse plein 12, Amsterdam")

myPigeon.printHomeAddress() //address: LEIDSE PLEIN 12, AMSTERDAM

func printAddress(animal: Domesticatable) {
  animal.printHomeAddress()
}
printAddress(animal: myPigeon) // Leidse plein 12, Amsterdam

/*
protocol Domesticatable {
  var homeAddress: String? { get }
  var hasHomeAddress: Bool { get }
  
  func printHomeAddress()
}

extension Domesticatable {
  var hasHomeAddress: Bool {
    return homeAddress != nil
  }
  
  func printHomeAddress() {
    if let address = homeAddress {
      print(address)
    }
  }
}
*/
