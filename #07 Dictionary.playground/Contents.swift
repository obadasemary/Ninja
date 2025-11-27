import UIKit

var greeting = "Hello, playground"

var emptyDictionary: [String: Int] = [:]
var studentScores: [String: Int] = ["Alice": 85, "Bob": 92, "Charlie": 78]

print(studentScores["Alice"]!)

studentScores["David"] = 88

print(studentScores["David"]!)

studentScores["Bob"] = 95
print("Student scores after updating Bob's score: \( studentScores["Bob"]!)")

studentScores.removeValue(forKey: "Charlie")
print("Student scores after removing Charlie: \(studentScores)")

print("Is emptyDictionary empty? \(emptyDictionary.isEmpty)")

print("Number of students: \(studentScores.count)")

print("Iterating over studentScores:")
for (student, score) in studentScores {
    print("\(student): \(score)")
}

print("Iterating over student names:")
for name in studentScores.keys {
    print(name)
}

print("Iterating over student scores:")
for scores in studentScores.values {
    print(scores)
}
