/*
    Nested Types
    
    You can define types within other types to create a clear hierarchical structure. This is particularly useful when a type is only relevant within the context of another type.
    
    In this example, we define a `Car` struct that contains a nested `CarType` enum and a nested `Engine` struct. The `CarType` enum categorizes different types of cars, while the `Engine` struct holds information about the car's engine.
*/

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

