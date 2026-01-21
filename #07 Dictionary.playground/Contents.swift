// #07 Dictionary
//
// A Dictionary is an unordered collection of key-value pairs.
// Each key is unique and maps to exactly one value.
//
// Key characteristics:
// - Unordered: Key-value pairs have no defined order
// - Unique keys: Each key can appear only once in a dictionary
// - Fast lookup: O(1) average time for accessing values by key
// - Type-safe: Keys must be of one type, values must be of another type
// - Hashable keys: Keys must conform to the Hashable protocol
//
// Common use cases:
// - Storing associated data (user profiles, settings, configurations)
// - Mapping identifiers to objects (ID to user, name to score)
// - Counting occurrences (word frequency, character counts)
// - Caching and lookup tables

import Foundation

// MARK: - Creating Dictionaries

// Empty dictionary with explicit type annotation
var emptyDictionary: [String: Int] = [:]

// Dictionary initialized with key-value pairs
// Format: [key1: value1, key2: value2, ...]
var studentScores: [String: Int] = ["Alice": 85, "Bob": 92, "Charlie": 78]

// MARK: - Accessing Dictionary Values

// Access value by key (returns Optional)
// Using optional binding is safer than force unwrapping
if let aliceScore = studentScores["Alice"] {
    print("Alice's score: \(aliceScore)")
}

// MARK: - Adding and Updating Values

// Add a new key-value pair
// If the key doesn't exist, it will be added
studentScores["David"] = 88
print("Student scores after adding David: \(studentScores)")

// Access the newly added value
if let davidScore = studentScores["David"] {
    print("David's score: \(davidScore)")
}

// Update an existing value
// If the key exists, its value will be updated
studentScores["Bob"] = 95
print("Student scores after updating Bob's score: \(studentScores)")

// Alternative: updateValue method returns the old value
if let oldScore = studentScores.updateValue(90, forKey: "Alice") {
    print("Alice's old score was \(oldScore), new score is \(studentScores["Alice"]!)")
}

// MARK: - Removing Values

// Remove a key-value pair using removeValue
// Returns the removed value or nil if key doesn't exist
if let removedScore = studentScores.removeValue(forKey: "Charlie") {
    print("Removed Charlie with score: \(removedScore)")
}
print("Student scores after removing Charlie: \(studentScores)")

// Alternative: Set value to nil to remove
studentScores["Charlie"] = nil  // No effect since Charlie is already removed

// MARK: - Checking Dictionary Properties

// Check if dictionary is empty
print("\nIs emptyDictionary empty? \(emptyDictionary.isEmpty)")

// Get the number of key-value pairs
print("Number of students: \(studentScores.count)")

// MARK: - Iterating Over Dictionaries

// Iterate over key-value pairs
// Each element is a tuple of (key, value)
print("\nIterating over studentScores:")
for (student, score) in studentScores {
    print("\(student): \(score)")
}

// Iterate over keys only
print("\nIterating over student names:")
for name in studentScores.keys {
    print(name)
}

// Iterate over values only
print("\nIterating over student scores:")
for score in studentScores.values {
    print(score)
}

// MARK: - Common Dictionary Operations

// Get all keys as an array
let studentNames = Array(studentScores.keys)
print("\nAll student names: \(studentNames)")

// Get all values as an array
let scores = Array(studentScores.values)
print("All scores: \(scores)")

// Check if dictionary contains a specific key
let hasAlice = studentScores.keys.contains("Alice")
print("\nDoes dictionary contain Alice? \(hasAlice)")

// Safe access with default value using nil coalescing
let charlieScore = studentScores["Charlie"] ?? 0
print("Charlie's score (with default): \(charlieScore)")

// MARK: - Merging Dictionaries

// Create another dictionary to merge
let newStudents: [String: Int] = ["Eve": 88, "Frank": 91]

// Merge dictionaries (values from newStudents will overwrite existing keys)
studentScores.merge(newStudents) { (current, new) in new }
print("\nStudent scores after merging: \(studentScores)")

// Alternative: Use + operator (requires custom implementation or use merge)
var allScores = studentScores
for (key, value) in newStudents {
    allScores[key] = value
}

// MARK: - Filtering and Transforming Dictionaries

// Filter dictionary to get students with score > 90
let highScorers = studentScores.filter { $0.value > 90 }
print("\nStudents with scores > 90: \(highScorers)")

// Map dictionary values (transform scores to letter grades)
let letterGrades = studentScores.mapValues { score -> String in
    switch score {
    case 90...100: return "A"
    case 80..<90: return "B"
    case 70..<80: return "C"
    default: return "F"
    }
}
print("\nLetter grades: \(letterGrades)")

// MARK: - Grouping with Dictionary

// Group array elements by a key
let names = ["Alice", "Bob", "Charlie", "Anna", "David", "Alex"]
let groupedByFirstLetter = Dictionary(grouping: names) { String($0.first!) }
print("\nNames grouped by first letter: \(groupedByFirstLetter)")

// MARK: - Common Use Cases

// 1. Counting occurrences (word frequency)
let words = ["apple", "banana", "apple", "cherry", "banana", "apple"]
var wordCount: [String: Int] = [:]
for word in words {
    wordCount[word, default: 0] += 1
}
print("\nWord count: \(wordCount)")

// 2. Creating a lookup table (mapping IDs to names)
let userLookup: [Int: String] = [
    101: "Alice",
    102: "Bob",
    103: "Charlie"
]
if let userName = userLookup[102] {
    print("\nUser with ID 102: \(userName)")
}

// 3. Configuration/Settings storage
let appSettings: [String: Any] = [
    "darkMode": true,
    "fontSize": 14,
    "language": "en"
]
print("\nApp settings: \(appSettings)")
