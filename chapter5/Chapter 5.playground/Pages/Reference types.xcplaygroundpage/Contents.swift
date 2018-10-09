class Pet {
  var name: String
  
  init(name: String) {
    self.name = name
  }
}

func printName(for pet: Pet) {
  print(pet.name)
}

let cat = Pet(name: "Misty")
printName(for: cat)

func printName2(for pet: Pet) {
  print(pet.name)
  pet.name = "Jeff"
}

let dog = Pet(name: "Bingo")
printName2(for: dog) // Bingo
print(dog.name)
