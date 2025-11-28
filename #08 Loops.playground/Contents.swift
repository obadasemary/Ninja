import Foundation

var greeting = "Hello, playground"

// MARK: - For loops

for i in 1...5 {
    print(i)
}

for _ in 1...5 {
    print("Hello")
}

for num in stride(from: 1, through: 11, by: 2) {
    print(num)
}

for num in stride(from: 1, to: 11, by: 2) {
    print(num)
}

let students: [String] = ["Alice", "Bob", "Charlie"]

for student in students {
    print("Hello, \(student)!")
}

// MARK: - While loops

var userInput: String?

while userInput != "exit" {
    userInput = ["continue", "stop", "exit"].randomElement()
    print("User input: \(String(describing: userInput))")
}

// MARK: - Repeat While loops

repeat {
    userInput = "exit"
    print("User input: \(String(describing: userInput))")
} while userInput != "exit"

