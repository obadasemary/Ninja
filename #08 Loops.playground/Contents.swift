import Foundation

var greeting = "Hello, playground"

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
