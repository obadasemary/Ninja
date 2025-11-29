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
        return "This is a \(type) with a \(engine.horsePower) hp engine."
    }
}
