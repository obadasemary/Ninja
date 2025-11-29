import Foundation

var greeting = "Hello, playground"

struct Car {
    
    enum CarType {
        case sedan, suv, truck
    }
    
    struct Engine {
        let horsePower: Int
        let fuelType: String
    }
    
    let type: CarType
    let engine: Engine
    
    func description() -> String {
        return "This car is a \(type) with a \(engine.horsePower) HP, running \(engine.fuelType) fuel."
    }
}

let myCar = Car(
    type: .suv,
    engine: .init(
        horsePower: 250,
        fuelType: "petrol"
    )
)
print(myCar.description())

