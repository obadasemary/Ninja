// #05 Array
//
// An Array is an ordered collection of values of the same type.
// Arrays are one of the most commonly used data structures in Swift.
//
// Key characteristics:
// - Ordered: Elements maintain their insertion order
// - Indexed: Access elements by their position (0-based indexing)
// - Type-safe: All elements must be of the same type
// - Mutable: Can add, remove, or modify elements (when declared with var)
// - Dynamic: Size can grow or shrink as needed
//
// Common use cases:
// - Storing lists of items (users, products, tasks)
// - Maintaining ordered collections
// - Iterating through sequences of data

import Foundation

// MARK: - Creating Arrays

// Empty array using shorthand syntax
var emptyArray: [Int] = []

// Empty array using full Array type syntax
var emptyArray2: Array<Int> = []

// Array initialized with values
var numbers: [Int] = [1, 2, 3, 4, 5]
print("Numbers: \(numbers)")

// Create an array with repeated values
// Useful for initializing arrays with default values
var repeatedValues = Array(repeating: 0, count: 5)  // [0, 0, 0, 0, 0]
print("Repeated Values: \(repeatedValues)")

// MARK: - Combining Arrays

// Concatenate two arrays using the + operator
let array1 = [1, 2, 3]
let array2 = [6, 7, 8]
let concatenatedArray = array1 + array2  // [1, 2, 3, 6, 7, 8]
print("Concatenated Array: \(concatenatedArray)")

// MARK: - Checking Array Properties

// Check if an array is empty
print("Is empty: \(emptyArray.isEmpty)")
print("Is not empty: \(!numbers.isEmpty)")

// Get the number of elements in an array
print("Array count: \(numbers.count)")

// MARK: - Modifying Arrays

// Add an element to the end of the array
numbers.append(6)  // [1, 2, 3, 4, 5, 6]
print("Updated Numbers: \(numbers)")

// MARK: - Accessing Array Elements

// Access element by index (0-based)
let firstNumber = numbers[0]  // Gets 1
print("First number: \(firstNumber)")

// Update element at specific index
numbers[1] = 100  // Changes second element from 2 to 100
print("After updating index 1: \(numbers)")

// Insert element at specific position
// Shifts all elements after the index to the right
numbers.insert(99, at: 2)  // Insert 99 at index 2
print("After inserting 99 at index 2: \(numbers)")

// Remove element at specific index
// Shifts all elements after the index to the left
let removedElement = numbers.remove(at: 4)
print("Removed element: \(removedElement)")
print("After removal: \(numbers)")

// MARK: - Iterating Over Arrays

// Simple iteration over array values
print("\nIterating over numbers array:")
for number in numbers {
    print(number)
}

// Iteration with both index and value using enumerated()
// Returns a sequence of (index, value) tuples
print("\nIterating with index and value:")
for (index, value) in numbers.enumerated() {
    print("Index: \(index), Value: \(value)")
}

// MARK: - Common Array Operations

// Get first and last elements (returns Optional)
if let firstElement = numbers.first {
    print("\nFirst element: \(firstElement)")
}

if let lastElement = numbers.last {
    print("Last element: \(lastElement)")
}

// Check if array contains a specific value
let containsFive = numbers.contains(5)
print("\nDoes array contain 5? \(containsFive)")

// Get index of an element
if let indexOfHundred = numbers.firstIndex(of: 100) {
    print("Index of 100: \(indexOfHundred)")
}

// Sort an array
let unsortedNumbers = [5, 2, 8, 1, 9]
let sortedNumbers = unsortedNumbers.sorted()  // Returns new sorted array
print("\nOriginal: \(unsortedNumbers)")
print("Sorted: \(sortedNumbers)")

// Filter array elements
let filteredNumbers = numbers.filter { $0 > 10 }
print("\nNumbers greater than 10: \(filteredNumbers)")

// Map array elements (transform each element)
let doubledNumbers = numbers.map { $0 * 2 }
print("Doubled numbers: \(doubledNumbers)")

// Reduce array to single value
let sum = numbers.reduce(0, +)  // Sum all numbers
print("Sum of all numbers: \(sum)")
