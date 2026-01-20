// #06 Set
//
// A Set is an unordered collection of unique values of the same type.
// Sets are useful when:
// - You need to ensure uniqueness (no duplicates)
// - Order doesn't matter
// - You need fast lookup/membership testing
// - You want to perform mathematical set operations (union, intersection, etc.)
//
// Key characteristics:
// - Unordered: Elements have no defined order
// - Unique: Automatically removes duplicates
// - Hashable: Elements must conform to Hashable protocol
// - Fast: O(1) average time for contains, insert, and remove operations

import Foundation

// MARK: - Creating Sets

// Empty set with explicit type annotation
var emptySet: Set<Int> = []

// Set initialized with values
// Note: Sets are unordered, so the printed order may vary
var numbersSet: Set = [1, 2, 5, 6, 7, 8, 9, 10]
print("Value of elements in numbersSet: \(numbersSet)")

// Sets automatically remove duplicates
// Even though we specify duplicates, the set will only store unique values
let duplicateNumbers: Set = [1, 2, 2, 3, 4, 4, 5]
print("Value of elements in duplicateNumbers: \(duplicateNumbers)")  // Output: [1, 2, 3, 4, 5] (in some order)

// MARK: - Checking Set Properties

// Check if a set is empty
print("Is emptySet empty? \(emptySet.isEmpty)")
print("Is numbersSet empty? \(numbersSet.isEmpty)")

// Get the number of elements in a set
print("Number of elements in numbersSet: \(numbersSet.count)")

// MARK: - Searching for Elements

// Check if a set contains a specific value (O(1) operation)
print("Does numbersSet contain 3? \(numbersSet.contains(3))")

// MARK: - Modifying Sets

// Insert a new element into the set
// Returns a tuple: (inserted: Bool, memberAfterInsert: Element)
numbersSet.insert(11)
print("Updated numbersSet: \(numbersSet)")

// Remove an element from the set
// Returns the removed element if it existed, or nil if not found
if let removedValue = numbersSet.remove(10) {
    print("Removed value: \(removedValue)")
} else {
    print("Value not found in set")
}

print("Numbers set after removal: \(numbersSet)")

// MARK: - Set Operations
// Swift provides mathematical set operations for combining, comparing, and analyzing sets

let setA: Set = [1, 2, 3, 4]
let setB: Set = [3, 4, 5, 6]

// Union: Creates a new set with all unique values from both sets
// Result: All elements from setA and setB combined
let unionSet = setA.union(setB)  // [1, 2, 3, 4, 5, 6]

// Intersection: Creates a new set with only values that appear in BOTH sets
// Result: Only elements that exist in both setA and setB
let intersectionSet = setA.intersection(setB)  // [3, 4]

// Subtracting: Creates a new set with values in first set but NOT in second set
// Result: Elements in setA that are not in setB
let subtractSet = setA.subtracting(setB)  // [1, 2]

// Symmetric Difference: Creates a new set with values in EITHER set, but NOT in BOTH
// Result: Elements that are unique to each set (opposite of intersection)
let symmetricDifferenceSet = setA.symmetricDifference(setB)  // [1, 2, 5, 6]

// MARK: - Set Comparisons
// Swift provides methods to compare relationships between sets

let setC: Set = [1, 2]
let setD: Set = [1, 2, 3, 4, 5, 6]

// Subset: Check if all elements of one set are contained in another
// setC is a subset of setD because all elements of setC (1, 2) exist in setD
print("Is setC a subset of setD? \(setC.isSubset(of: setD))")  // true

// Superset: Check if one set contains all elements of another
// setD is a superset of setC because it contains all elements from setC plus more
print("Is setD a superset of setC? \(setD.isSuperset(of: setC))")  // true

// Equality: Check if two sets contain exactly the same elements
// Order doesn't matter for sets, only the values
print("Are setA and setC equal? \(setA == setC)")  // false (different elements)
print("Are setA and setD equal? \(setA == setD)")  // false (different elements)

// Disjoint: Check if two sets have NO elements in common
// Two sets are disjoint if their intersection is empty
let setE: Set = [18, 20, 33, 43, 50]
print("Are setC and setE disjoint? \(setC.isDisjoint(with: setE))")  // true (no common elements)

// MARK: - Iterating Over a Set

// Sets are unordered, so iteration order is not guaranteed
// Each time you run this, the order might be different
print("Iterating over numbersSet:")
for number in numbersSet {
    print(number)
}

// If you need ordered iteration, use sorted()
// This returns a sorted array of the set's elements
print("\nIterating over numbersSet in sorted order:")
for number in numbersSet.sorted() {
    print(number)
}

// MARK: - Common Use Cases for Sets

// 1. Removing duplicates from an array
let numbersWithDuplicates = [1, 2, 2, 3, 3, 3, 4, 5, 5]
let uniqueNumbers = Array(Set(numbersWithDuplicates))  // Convert array -> set -> array
print("\nOriginal array: \(numbersWithDuplicates)")
print("Unique numbers: \(uniqueNumbers)")

// 2. Fast membership testing
let allowedUsernames: Set = ["admin", "user", "guest", "moderator"]
let usernameToCheck = "admin"
if allowedUsernames.contains(usernameToCheck) {
    print("\n'\(usernameToCheck)' is an allowed username")
}

// 3. Finding common elements between collections
let studentSetA: Set = ["Alice", "Bob", "Charlie", "David"]
let studentSetB: Set = ["Charlie", "David", "Eve", "Frank"]
let commonStudents = studentSetA.intersection(studentSetB)
print("\nStudents in both classes: \(commonStudents)")


