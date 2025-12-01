import Foundation

var greeting = "Hello, playground"

var temperatureInCelsius: Double = 25.0
var temperatureInFahrenheit: Double = (temperatureInCelsius * 9/5) + 32

print("The temperature is \(temperatureInFahrenheit) in Fahrenheit.")

if temperatureInCelsius <= 0 {
    print("It's very cold!. Consider wearing a scarf.")
} else if temperatureInCelsius >= 30 {
    print("It's warm today! Don't forget your sunscreen.")
}

let weatherAdvice = if temperatureInCelsius <= 0 {
    "It's very cold!. Consider wearing a scarf."
} else if temperatureInCelsius >= 30 {
    "It's warm today! Don't forget your sunscreen."
} else {
    "It's not that cold or warm today. Enjoy your day!"
}

let someCharacter: Character = "z"

switch someCharacter {
case "a":
    print("The character is 'a'.")
case "b":
    print("The character is 'b'.")
case "z":
    print("The character is 'z'.")
default:
    print("The character is neither 'a' nor 'b', nor 'z'.")
}

// MARK: - Compound Cases

switch someCharacter {
case "a", "e", "i", "o", "u":
    print("\(someCharacter) is a vowel.")
case "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z":
    print("\(someCharacter) is a consonant.")
default:
    print("\(someCharacter) isn't a letter of the alphabet.")
}

// MARK: - Ranges is Switch

let approximateCount: Int = 62
let naturalCount: String

switch approximateCount {
case 0:
    naturalCount = "no"
case 1..<5:
    naturalCount = "a few"
case 5..<12:
    naturalCount = "several"
case 12..<100:
    naturalCount = "dozens (or more)"
case 100...:
    naturalCount = "hundreds (or more)"
default:
    fatalError("Unexpectedly large count")
}

// MARK: - Value Binding

let anotherPoint = (2, 0)

switch anotherPoint {
case (let x, 0):
    print("The point is on the x-axis with an x-coordinate of \(x).")
case (0, let y):
    print("The point is on the y-axis with a y-coordinate of \(y).")
case (let x, let y):
    print("The point is somewhere else at coordinates (\(x), \(y)).")
}

// MARK: - Tuples & Where

let somePoint = (1, -1)

switch somePoint {
case let (x, y) where x == y:
    print("(\(x), \(y)) is on the line x == y.")
case let (x, y) where x == -y:
    print("(\(x), \(y)) is on the line x == -y.")
case let (x, y):
    print("(\(x), \(y)) is just some arbitrary point.")
}
