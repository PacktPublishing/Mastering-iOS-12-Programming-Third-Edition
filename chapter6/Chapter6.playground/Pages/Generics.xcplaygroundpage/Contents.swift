protocol PlantType {
  var latinName: String { get }
}

struct Grass: PlantType {
  let latinName: String
}

struct Flower: PlantType {
  let latinName: String
}

protocol HerbivoreType {
  associatedtype Plant: PlantType
  
  var plantsEaten: [Plant] { get set }
  
  mutating func eat(plant: Plant)
}

extension HerbivoreType {
  mutating func eat(plant: Plant) {
    print("eating a (plant.latinName)")
    plantsEaten.append(plant)
  }
}

struct Cow<Plant: PlantType>: HerbivoreType {
  var plantsEaten = [Plant]()
}

let grassCow = Cow<Grass>()
let flowerCow = Cow<Flower>()

func simpleMap<T, U>(_ input: [T], transform: (T) -> U) -> [U] {
  var output = [U]()
  
  for item in input {
    output.append(transform(item))
  }
  
  return output
}

let result = simpleMap([1, 2, 3]) { item in
  return item * 2
}

print(result) // [2, 4, 6]
