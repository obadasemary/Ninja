import Foundation

// MARK: - Constants & Variables in Swift

/*
 Constants and variables are fundamental building blocks in Swift.
 - Constants (let): Values that cannot be changed after initial assignment
 - Variables (var): Values that can be modified after initial assignment
 */

// MARK: - Variables (var)

// Declaring a variable with type inference
var greeting = "Hello, World!"
print("Original greeting: \(greeting)")

// Variables can be reassigned
greeting = "Hello, Swift!"
print("Updated greeting: \(greeting)")

// Multiple variables on a single line
var x = 0, y = 1, z = 2
print("x: \(x), y: \(y), z: \(z)")

// Variables with different types
var age = 25
var price = 19.99
var isActive = true
var username = "ninja_coder"

print("\nVariable Examples:")
print("Age: \(age)")
print("Price: $\(price)")
print("Is Active: \(isActive)")
print("Username: \(username)")

// MARK: - Constants (let)

// Declaring a constant
let pi = 3.14159
print("\nPi value: \(pi)")

// Constants cannot be reassigned (uncommenting the line below will cause an error)
// pi = 3.14  // Error: Cannot assign to value: 'pi' is a 'let' constant

let maxAttempts = 3
let apiKey = "abc123xyz789"
let isProduction = false

print("\nConstant Examples:")
print("Max Attempts: \(maxAttempts)")
print("API Key: \(apiKey)")
print("Is Production: \(isProduction)")

// Multiple constants on a single line
let width = 100, height = 200
print("Dimensions: \(width)x\(height)")

// MARK: - Type Annotations

/*
 Type annotations explicitly specify the type of a variable or constant.
 Syntax: var/let name: Type = value
 */

// Explicit type annotations
var explicitString: String = "Hello"
var explicitInt: Int = 42
var explicitDouble: Double = 3.14
var explicitBool: Bool = true

print("\nExplicit Type Annotations:")
print("String: \(explicitString)")
print("Int: \(explicitInt)")
print("Double: \(explicitDouble)")
print("Bool: \(explicitBool)")

// Type annotation without initial value
var userName: String
userName = "SwiftNinja"
print("\nDeferred initialization: \(userName)")

// Type annotation with multiple variables
var red: Int, green: Int, blue: Int
red = 255
green = 128
blue = 64
print("RGB Color: (\(red), \(green), \(blue))")

// MARK: - Common Data Types

// Integer types
var smallNumber: Int8 = 127          // -128 to 127
var regularNumber: Int = 1000        // Platform-dependent (Int32 or Int64)
var bigNumber: Int64 = 9223372036854775807

print("\nInteger Types:")
print("Int8: \(smallNumber)")
print("Int: \(regularNumber)")
print("Int64: \(bigNumber)")

// Unsigned integers
var positiveOnly: UInt = 42          // Only positive numbers
print("UInt: \(positiveOnly)")

// Floating-point types
var floatNumber: Float = 3.14159     // 32-bit floating point
var doubleNumber: Double = 3.14159265359  // 64-bit floating point (preferred)

print("\nFloating-Point Types:")
print("Float: \(floatNumber)")
print("Double: \(doubleNumber)")

// String and Character
var message: String = "Swift is awesome!"
var initial: Character = "S"

print("\nString & Character:")
print("Message: \(message)")
print("Initial: \(initial)")

// Boolean
var isSwiftFun: Bool = true
var hasErrors: Bool = false

print("\nBoolean:")
print("Is Swift fun? \(isSwiftFun)")
print("Has errors? \(hasErrors)")

// MARK: - Type Inference vs Type Annotation

/*
 Swift can automatically infer types based on the initial value.
 Use type annotations when:
 - You need a specific type different from the inferred one
 - You want to declare without immediate initialization
 - You want to make the code more explicit/readable
 */

// Type inference (Swift determines the type)
let inferredInt = 42                 // Inferred as Int
let inferredDouble = 3.14            // Inferred as Double
let inferredString = "Hello"         // Inferred as String
let inferredBool = true              // Inferred as Bool

print("\nType Inference:")
print("Inferred Int: \(type(of: inferredInt)) = \(inferredInt)")
print("Inferred Double: \(type(of: inferredDouble)) = \(inferredDouble)")
print("Inferred String: \(type(of: inferredString)) = \(inferredString)")
print("Inferred Bool: \(type(of: inferredBool)) = \(inferredBool)")

// When you need a different type
let explicitFloat: Float = 3.14      // Without annotation, would be Double
print("\nExplicit Float: \(type(of: explicitFloat)) = \(explicitFloat)")

// MARK: - Naming Conventions

/*
 Swift naming best practices:
 - Use camelCase for variables and constants
 - Start with lowercase letter
 - Use descriptive names
 - Constants can use ALL_CAPS for global constants, but camelCase is preferred
 */

let anotherUserName = "John"
let userAge = 30
var itemCount = 0
var isLoggedIn = false
let maximumLoginAttempts = 5
let π = 3.14159  // Unicode characters are allowed!

print("\nNaming Examples:")
print("userName: \(anotherUserName)")
print("userAge: \(userAge)")
print("itemCount: \(itemCount)")
print("isLoggedIn: \(isLoggedIn)")
print("maximumLoginAttempts: \(maximumLoginAttempts)")
print("π: \(π)")

// MARK: - Type Safety and Type Conversion

/*
 Swift is a type-safe language. You cannot mix types without explicit conversion.
 */

let integerValue: Int = 10
let doubleValue: Double = 3.14

// This would cause an error:
// let result = integerValue + doubleValue  // Error: Cannot convert value of type 'Int' to expected argument type 'Double'

// Correct way: explicit type conversion
let result = Double(integerValue) + doubleValue
print("\nType Conversion:")
print("Result: \(result)")

// Converting between numeric types
let largeNumber: Int = 1000
let smallerNumber = Int8(largeNumber % 128)  // Be careful with overflow
print("Converted Int8: \(smallerNumber)")

// Converting to String
let number = 42
let numberString = String(number)
print("Number as String: \"\(numberString)\"")

// MARK: - Practical Examples

// Example 1: User Profile
let userId: Int = 12345
var userDisplayName: String = "Swift Ninja"
var userPoints: Int = 1000
let accountCreationDate = "2024-01-15"
var isPremiumUser: Bool = false

print("\n--- User Profile ---")
print("ID: \(userId)")
print("Name: \(userDisplayName)")
print("Points: \(userPoints)")
print("Created: \(accountCreationDate)")
print("Premium: \(isPremiumUser)")

// Updating variable values
userPoints += 50
isPremiumUser = true
print("\nAfter update:")
print("Points: \(userPoints)")
print("Premium: \(isPremiumUser)")

// Example 2: Shopping Cart
var cartItemCount: Int = 0
var cartTotal: Double = 0.0
let taxRate: Double = 0.08
let shippingCost: Double = 5.99

cartItemCount = 3
cartTotal = 45.99

let subtotal = cartTotal
let tax = subtotal * taxRate
let finalTotal = subtotal + tax + shippingCost

print("\n--- Shopping Cart ---")
print("Items: \(cartItemCount)")
print("Subtotal: $\(String(format: "%.2f", subtotal))")
print("Tax: $\(String(format: "%.2f", tax))")
print("Shipping: $\(String(format: "%.2f", shippingCost))")
print("Total: $\(String(format: "%.2f", finalTotal))")

// MARK: - Key Takeaways

print("\n=== Key Takeaways ===")
print("✓ Use 'var' for values that change")
print("✓ Use 'let' for values that stay constant")
print("✓ Swift infers types automatically when possible")
print("✓ Use type annotations for clarity or specific types")
print("✓ Swift is type-safe - explicit conversion required between types")
print("✓ Choose descriptive, camelCase names for readability")
