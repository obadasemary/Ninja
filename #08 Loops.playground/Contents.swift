// #08 Loops
//
// Loops allow you to execute a block of code multiple times.
// Swift provides several types of loops for different scenarios.
//
// Loop types:
// - for-in: Iterate over sequences (ranges, arrays, dictionaries, etc.)
// - while: Repeat while a condition is true (condition checked before execution)
// - repeat-while: Execute at least once, then repeat while condition is true
//
// Control flow statements:
// - break: Exit the loop immediately
// - continue: Skip the current iteration and move to the next one
// - return: Exit the entire function (not just the loop)

import Foundation

// MARK: - For-In Loops

// Basic for-in loop with closed range operator (...)
// Closed range includes both start and end values
print("Counting from 1 to 5:")
for i in 1...5 {
    print(i)  // Prints: 1, 2, 3, 4, 5
}

// Using underscore (_) when you don't need the loop variable
// Useful when you just want to repeat an action N times
print("\nRepeating action 5 times:")
for _ in 1...5 {
    print("Hello")
}

// Half-open range operator (..<)
// Excludes the end value (useful for 0-based indexing)
print("\nCounting from 0 to 4 (half-open range):")
for i in 0..<5 {
    print(i)  // Prints: 0, 1, 2, 3, 4
}

// Using stride for custom step sizes
// stride(from:through:by:) - includes the end value
print("\nOdd numbers from 1 to 11 (through):")
for num in stride(from: 1, through: 11, by: 2) {
    print(num)  // Prints: 1, 3, 5, 7, 9, 11
}

// stride(from:to:by:) - excludes the end value
print("\nOdd numbers from 1 to 11 (to):")
for num in stride(from: 1, to: 11, by: 2) {
    print(num)  // Prints: 1, 3, 5, 7, 9
}

// Counting backwards with stride
print("\nCountdown from 10 to 1:")
for num in stride(from: 10, through: 1, by: -1) {
    print(num)
}

// MARK: - Iterating Over Collections

// Iterating over an array
let students: [String] = ["Alice", "Bob", "Charlie"]

print("\nGreeting students:")
for student in students {
    print("Hello, \(student)!")
}

// Iterating with index and value using enumerated()
print("\nStudent roster:")
for (index, student) in students.enumerated() {
    print("\(index + 1). \(student)")
}

// Iterating over a dictionary
let scores = ["Alice": 85, "Bob": 92, "Charlie": 78]
print("\nStudent scores:")
for (name, score) in scores {
    print("\(name): \(score)")
}

// Iterating over a range in reverse
print("\nReverse countdown:")
for i in (1...5).reversed() {
    print(i)  // Prints: 5, 4, 3, 2, 1
}

// MARK: - While Loops
// While loops check the condition BEFORE executing the loop body
// If the condition is false initially, the loop body never executes

var countdown = 5
print("\nWhile loop countdown:")
while countdown > 0 {
    print(countdown)
    countdown -= 1
}
print("Liftoff!")

// Example: Processing until a condition is met
var userInput: String?
var attempts = 0
print("\nSimulating user input (while loop):")
while userInput != "exit" && attempts < 5 {
    userInput = ["continue", "stop", "exit"].randomElement()
    print("Attempt \(attempts + 1): User input = \(userInput ?? "nil")")
    attempts += 1
}

// MARK: - Repeat-While Loops
// Repeat-while loops execute the body FIRST, then check the condition
// The loop body always executes at least once, even if condition is false

print("\nRepeat-while loop (executes at least once):")
var counter = 0
repeat {
    print("Counter: \(counter)")
    counter += 1
} while counter < 3

// Example where condition is false from the start
print("\nRepeat-while with initially false condition:")
var value = 10
repeat {
    print("This executes once even though value (\(value)) is already >= 10")
    value += 1
} while value < 10

// MARK: - Break Statement
// Break immediately exits the loop

print("\nUsing break to exit early:")
for i in 1...10 {
    if i == 5 {
        print("Breaking at \(i)")
        break
    }
    print(i)
}

// Example: Finding first match
let numbers = [3, 7, 12, 5, 9, 15]
print("\nFinding first number greater than 10:")
for num in numbers {
    if num > 10 {
        print("Found: \(num)")
        break  // Exit loop once we find the first match
    }
}

// MARK: - Continue Statement
// Continue skips the current iteration and moves to the next one

print("\nUsing continue to skip even numbers:")
for i in 1...10 {
    if i % 2 == 0 {
        continue  // Skip even numbers
    }
    print(i)  // Only odd numbers are printed
}

// Example: Processing valid items only
let values = [5, -2, 8, -1, 10, 0, 3]
print("\nProcessing only positive numbers:")
for value in values {
    if value <= 0 {
        continue  // Skip non-positive numbers
    }
    print("Processing: \(value)")
}

// MARK: - Nested Loops
// Loops inside other loops

print("\nMultiplication table (nested loops):")
for i in 1...3 {
    for j in 1...3 {
        print("\(i) × \(j) = \(i * j)", terminator: "  ")
    }
    print()  // New line after each row
}

// Example: Creating a grid pattern
print("\nGrid pattern:")
for row in 1...4 {
    for col in 1...5 {
        print("*", terminator: " ")
    }
    print()  // New line after each row
}

// MARK: - Labeled Statements
// Labels allow you to break or continue outer loops from nested loops

print("\nUsing labeled statements:")
outerLoop: for i in 1...3 {
    for j in 1...3 {
        if i == 2 && j == 2 {
            print("Breaking outer loop at (\(i), \(j))")
            break outerLoop  // Breaks the outer loop, not just inner loop
        }
        print("(\(i), \(j))")
    }
}

// Example: Finding a value in a 2D array
let matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
let target = 5
print("\nSearching for \(target) in matrix:")
searchLoop: for (rowIndex, row) in matrix.enumerated() {
    for (colIndex, value) in row.enumerated() {
        if value == target {
            print("Found \(target) at position (\(rowIndex), \(colIndex))")
            break searchLoop  // Exit both loops
        }
    }
}

// MARK: - forEach Method
// Alternative to for-in loops using closures

print("\nUsing forEach method:")
let fruits = ["Apple", "Banana", "Cherry"]
fruits.forEach { fruit in
    print(fruit)
}

// Note: You cannot use break or continue with forEach
// For that, use a traditional for-in loop

// MARK: - Where Clause in For-In Loops
// Filter items directly in the loop declaration

print("\nLooping with where clause (only even numbers):")
for number in 1...10 where number % 2 == 0 {
    print(number)  // Only prints even numbers
}

// Example: Processing specific dictionary entries
let inventory = ["apples": 10, "bananas": 0, "oranges": 5, "grapes": 0]
print("\nItems in stock:")
for (item, quantity) in inventory where quantity > 0 {
    print("\(item): \(quantity)")
}

