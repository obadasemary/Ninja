// #09 Conditional Statements
//
// Conditional statements allow you to execute different code based on conditions.
// Swift provides several ways to control program flow based on conditions.
//
// Conditional types:
// - if/else if/else: Execute code based on Boolean conditions
// - switch: Match values against multiple patterns
// - ternary operator: Shorthand for simple if-else expressions
// - guard: Early exit when conditions aren't met
//
// Switch features:
// - Must be exhaustive (cover all possible values)
// - No implicit fallthrough (unlike C/C++)
// - Supports pattern matching, ranges, tuples, and where clauses

import Foundation

// MARK: - If Statements
// Basic conditional execution based on Boolean conditions

var temperatureInCelsius: Double = 25.0
var temperatureInFahrenheit: Double = (temperatureInCelsius * 9/5) + 32

print("The temperature is \(temperatureInFahrenheit)°F.")

// Simple if statement
if temperatureInCelsius > 30 {
    print("It's hot outside!")
}

// If-else statement
if temperatureInCelsius <= 0 {
    print("It's freezing! Wear a warm coat.")
} else {
    print("It's not freezing.")
}

// If-else if-else chain (multiple conditions)
if temperatureInCelsius <= 0 {
    print("It's very cold! Consider wearing a scarf.")
} else if temperatureInCelsius >= 30 {
    print("It's warm today! Don't forget your sunscreen.")
} else {
    print("The weather is moderate.")
}

// MARK: - If Expressions (Swift 5.9+)
// Use if as an expression to assign values directly

let weatherAdvice = if temperatureInCelsius <= 0 {
    "It's very cold! Consider wearing a scarf."
} else if temperatureInCelsius >= 30 {
    "It's warm today! Don't forget your sunscreen."
} else {
    "It's not that cold or warm today. Enjoy your day!"
}
print("Weather advice: \(weatherAdvice)")

// MARK: - Ternary Conditional Operator
// Shorthand for simple if-else expressions: condition ? valueIfTrue : valueIfFalse

let age = 20
let canVote = age >= 18 ? "Yes" : "No"
print("Can vote: \(canVote)")

// Example: Setting values based on condition
let score = 85
let grade = score >= 60 ? "Pass" : "Fail"
print("Grade: \(grade)")

// Nested ternary (use sparingly for readability)
let number = 15
let description = number > 0 ? "positive" : number < 0 ? "negative" : "zero"
print("\(number) is \(description)")

// MARK: - Logical Operators
// Combine multiple conditions using &&, ||, and !

let hasTicket = true
let isVIP = false

// AND operator (&&) - both conditions must be true
if hasTicket && isVIP {
    print("Welcome to the VIP lounge!")
}

// OR operator (||) - at least one condition must be true
if hasTicket || isVIP {
    print("You can enter the venue.")
}

// NOT operator (!) - inverts the Boolean value
if !isVIP {
    print("Regular seating area.")
}

// Combining operators
let temperature = 22
let isSunny = true
if temperature > 20 && isSunny {
    print("Perfect day for a picnic!")
}

// MARK: - Switch Statements
// Match a value against multiple patterns
// Switch statements in Swift are powerful and must be exhaustive

let someCharacter: Character = "z"

// Basic switch with single cases
switch someCharacter {
case "a":
    print("The character is 'a'.")
case "b":
    print("The character is 'b'.")
case "z":
    print("The character is 'z'.")
default:
    print("The character is neither 'a', 'b', nor 'z'.")
}

// No implicit fallthrough in Swift
// Each case automatically breaks after execution (unlike C/C++)

// MARK: - Compound Cases
// Match multiple values in a single case using commas

switch someCharacter {
case "a", "e", "i", "o", "u":
    print("\(someCharacter) is a vowel.")
case "b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z":
    print("\(someCharacter) is a consonant.")
default:
    print("\(someCharacter) isn't a letter of the alphabet.")
}

// Example: Matching multiple numeric values
let dayNumber = 6
switch dayNumber {
case 1, 2, 3, 4, 5:
    print("It's a weekday.")
case 6, 7:
    print("It's the weekend!")
default:
    print("Invalid day number.")
}

// MARK: - Interval Matching (Ranges in Switch)
// Use ranges to check if values fall within intervals

let approximateCount: Int = 62
let naturalCount: String

switch approximateCount {
case 0:
    naturalCount = "no"
case 1..<5:
    // Half-open range: 1 to 4 (excluding 5)
    naturalCount = "a few"
case 5..<12:
    naturalCount = "several"
case 12..<100:
    naturalCount = "dozens (or more)"
case 100...:
    // Open-ended range: 100 and above
    naturalCount = "hundreds (or more)"
default:
    // This case is needed for negative numbers
    naturalCount = "negative count"
}
print("Count: \(naturalCount)")

// Example: Grade classification
let examScore = 85
switch examScore {
case 0..<50:
    print("Fail")
case 50..<60:
    print("Pass")
case 60..<70:
    print("Credit")
case 70..<80:
    print("Distinction")
case 80...100:
    // Closed range: 80 to 100 (including both)
    print("High Distinction")
default:
    print("Invalid score")
}

// MARK: - Tuples in Switch
// Switch can match against tuples to test multiple values

let httpStatus = (statusCode: 200, statusMessage: "OK")

switch httpStatus {
case (200, "OK"):
    print("Success!")
case (404, "Not Found"):
    print("Page not found.")
case (500, _):
    // Underscore (_) matches any value
    print("Server error with any message.")
case (_, "OK"):
    print("OK status with any code.")
default:
    print("Other status.")
}

// MARK: - Value Binding in Switch
// Bind matched values to temporary constants or variables

let anotherPoint = (2, 0)

switch anotherPoint {
case (let x, 0):
    // Matches any point on the x-axis (y = 0)
    // Binds the x-coordinate to constant 'x'
    print("The point is on the x-axis with an x-coordinate of \(x).")
case (0, let y):
    // Matches any point on the y-axis (x = 0)
    // Binds the y-coordinate to constant 'y'
    print("The point is on the y-axis with a y-coordinate of \(y).")
case (let x, let y):
    // Matches any other point
    // Binds both coordinates
    print("The point is somewhere else at coordinates (\(x), \(y)).")
}

// Shorthand: case let (x, y) is equivalent to case (let x, let y)
let point3D = (x: 5, y: 10, z: 15)
switch point3D {
case let (x, y, z):
    print("3D point at (\(x), \(y), \(z))")
}

// MARK: - Where Clauses in Switch
// Add additional conditions to cases using 'where'

let somePoint = (1, -1)

switch somePoint {
case let (x, y) where x == y:
    // Matches points on the line y = x
    print("(\(x), \(y)) is on the line x == y.")
case let (x, y) where x == -y:
    // Matches points on the line y = -x
    print("(\(x), \(y)) is on the line x == -y.")
case let (x, y):
    // Matches any other point
    print("(\(x), \(y)) is just some arbitrary point.")
}

// Example: Where clause with ranges
let temperature2 = 28
let humidity = 75

switch temperature2 {
case 20..<30 where humidity > 70:
    print("Warm and humid - might rain!")
case 20..<30:
    print("Pleasant temperature.")
case 30... where humidity > 80:
    print("Hot and humid - very uncomfortable!")
default:
    print("Other weather conditions.")
}

// MARK: - Fallthrough
// Explicitly fall through to the next case (like C/C++ switch)

let integerToDescribe = 5
var description = "The number \(integerToDescribe) is"

switch integerToDescribe {
case 2, 3, 5, 7, 11, 13, 17, 19:
    description += " a prime number, and also"
    fallthrough  // Continues to next case
case ...0:
    description += " less than or equal to zero."
case 1...10:
    description += " between 1 and 10."
default:
    description += " something else."
}
print(description)

// MARK: - Guard Statements
// Guard provides early exit when conditions aren't met
// Must exit the current scope (return, break, continue, throw)

func greetPerson(name: String?) {
    // Guard ensures name is not nil
    // If name is nil, the else block executes and returns
    guard let unwrappedName = name else {
        print("No name provided.")
        return
    }

    // unwrappedName is available here
    print("Hello, \(unwrappedName)!")
}

greetPerson(name: "Alice")
greetPerson(name: nil)

// Example: Multiple guard conditions
func processAge(age: Int?) {
    guard let validAge = age else {
        print("Age not provided.")
        return
    }

    guard validAge >= 0 else {
        print("Invalid age: cannot be negative.")
        return
    }

    guard validAge < 150 else {
        print("Invalid age: too high.")
        return
    }

    print("Processing age: \(validAge)")
}

processAge(age: 25)
processAge(age: nil)
processAge(age: -5)

// MARK: - Switch with Enums
// Switch is commonly used with enumerations

enum Direction {
    case north, south, east, west
}

let heading = Direction.north

switch heading {
case .north:
    print("Heading north.")
case .south:
    print("Heading south.")
case .east:
    print("Heading east.")
case .west:
    print("Heading west.")
}
// No default case needed - all enum cases are covered (exhaustive)

// Example: Enum with associated values
enum Barcode {
    case upc(Int, Int, Int, Int)
    case qrCode(String)
}

let productBarcode = Barcode.upc(8, 85909, 51226, 3)

switch productBarcode {
case .upc(let numberSystem, let manufacturer, let product, let check):
    print("UPC: \(numberSystem), \(manufacturer), \(product), \(check)")
case .qrCode(let code):
    print("QR Code: \(code)")
}

// Shorthand when all values are bound as let or var
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
    print("UPC-A: \(numberSystem), \(manufacturer), \(product), \(check)")
case let .qrCode(code):
    print("QR: \(code)")
}

// MARK: - Practical Examples

// Example 1: Login validation
func validateLogin(username: String?, password: String?) -> String {
    guard let user = username, !user.isEmpty else {
        return "Username is required."
    }

    guard let pass = password, !pass.isEmpty else {
        return "Password is required."
    }

    guard pass.count >= 8 else {
        return "Password must be at least 8 characters."
    }

    return "Login successful for \(user)!"
}

print(validateLogin(username: "alice", password: "password123"))
print(validateLogin(username: nil, password: "test"))
print(validateLogin(username: "bob", password: "short"))

// Example 2: Traffic light state machine
enum TrafficLight {
    case red, yellow, green
}

let currentLight = TrafficLight.red

switch currentLight {
case .red:
    print("Stop!")
case .yellow:
    print("Caution - prepare to stop.")
case .green:
    print("Go!")
}

// Example 3: Grading system with multiple criteria
func calculateGrade(score: Int, attendance: Int) -> String {
    switch (score, attendance) {
    case (90...100, 90...100):
        return "A+ (Excellent performance and attendance)"
    case (80..<90, 80...100):
        return "A (Good performance and attendance)"
    case (70..<80, 70...100):
        return "B (Satisfactory)"
    case (60..<70, _):
        return "C (Pass)"
    case (_, ..<50):
        return "F (Poor attendance - automatic fail)"
    default:
        return "F (Fail)"
    }
}

print(calculateGrade(score: 95, attendance: 95))
print(calculateGrade(score: 85, attendance: 90))
print(calculateGrade(score: 75, attendance: 40))
