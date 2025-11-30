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


