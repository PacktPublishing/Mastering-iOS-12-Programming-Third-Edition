protocol PlantType {
  var latinName: String { get }
}

protocol HerbivoreType {
  var plantsEaten: [PlantType] { get set }
  
  mutating func eat(plant: PlantType)
}

extension HerbivoreType {
  mutating func eat(plant: PlantType) {
    plantsEaten.append(plant)
  }
}

struct Grass: PlantType{
  var latinName = "Poaceae"
}

struct Pine: PlantType{
  var latinName = "Pinus"
}

struct Cow: HerbivoreType {
  var plantsEaten = [PlantType]()
}

protocol HerbivoreType2 {
  associatedtype Plant: PlantType
  
  var plantsEaten: [Plant] { get set }
  
  mutating func eat(plant: Plant)
}

extension HerbivoreType2 {
  mutating func eat(plant: Plant) {
    print("eating a (plant.latinName)")
    plantsEaten.append(plant)
  }
}

struct Cow2: HerbivoreType2 {
  var plantsEaten = [Grass]()
}

struct Carrot: PlantType {
  let latinName = "Daucus carota"
}

struct Rabbit: HerbivoreType2 {
  var plantsEaten = [Carrot]()
}
