import Foundation

var greeting = "Hello, playground"

var emptySet: Set<Int> = []

var numbersSet: Set = [1, 2, 5, 6, 7, 8, 9, 10]
print("Value of elements in numbersSet: \(numbersSet)")

let duplicateNumbers: Set = [1, 2, 2, 3, 4, 4, 5]
print("Value of elements in duplicateNumbers: \(duplicateNumbers)")

print("Is emptySet empty? \(emptySet.isEmpty)")
print("Is numbersSet empty? \(numbersSet.isEmpty)")
print("Number of elements in numbersSet: \(numbersSet.count)")

print("Does numbersSet contain 3? \(numbersSet.contains(3))")

numbersSet.insert(11)
print("Updated numbersSet: \(numbersSet)")


if let removedValue = numbersSet.remove(10) {
    print("Removed value: \(removedValue)")
} else {
    print("Value not fount in set")
}

print("Numbers set after removal: \(numbersSet)")

// MARK: - Set Operations

let setA: Set = [1, 2, 3, 4]
let setB: Set = [3, 4, 5, 6]

let unionSet = setA.union(setB)
let intersectionSet = setA.intersection(setB)
let subtractSet = setA.subtracting(setB)
let symmetricDifferenceSet = setA.symmetricDifference(setB)

// MARK: - Set Comparisons

let setC: Set = [1, 2]
let setD: Set = [1, 2, 3, 4, 5, 6]

print("Is setC a subset of setD? \(setC.isSubset(of: setD))")
print("Is setD a superst of setC? \(setD.isSuperset(of: setC))")

print("Are setA and setC equal? \(setA == setC)")
print("Are setA and setD equal? \(setA == setD)")

let setE: Set = [18, 20, 33, 43, 50]
print("Are setC and setE disjoint? \(setC.isDisjoint(with: setE))")

// MARK: - Iterating Ovar a Set

print("Iterating over numberSet:")
for number in numbersSet {
    print(number)
}

print("Iterating over numberSet in sorted order:")
for number in numbersSet.sorted() {
    print(number)
}


