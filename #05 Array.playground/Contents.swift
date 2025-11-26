//: A UIKit based Playground for presenting user interface
  
import Foundation

var greeting = "Hello, playground"

var emptyArray: [Int] = []
var emptyArray2: Array<Int> = []

var numbers: [Int] = [1, 2, 3, 4, 5]
print("Numbers: \(numbers)")

var repeatedValues = Array(repeating: 0, count: 5)
print("Repeated Values: \(repeatedValues)")

let array1 = [1, 2, 3]
let array2 = [6, 7, 8]
let concatenatedArray = array1 + array2
print("Concatenated Array: \(concatenatedArray)")

print("Is empty: \(emptyArray.isEmpty)")
print("Is not empty: \(!numbers.isEmpty)")

print("Array count: \(numbers.count)")

numbers.append(6)
print("Updated Numbers: \(numbers)")

let firstnumber = numbers[0]

numbers[1] = 100

numbers.insert(99, at: 2)
print("Updated Numbers: \(numbers)")

numbers.remove(at: 4)

print("Iterating over numbers array:")

for number in numbers {
    print(number)
}

print("Iterating with index and value:")

for (index, value) in numbers.enumerated() {
    print("Index: \(index), Value: \(value)")
}
