import UIKit

var greeting = "Hello, playground"


func CodelandUsernameValidation(_ str: String) -> Bool {
    
    // code goes here
    // Note: feel free to modify the return type of this function
    let arrayString = Array(str)
    if arrayString.count >= 4 || arrayString.count <= 25 {
        if arrayString.last != "_" {
            if let firstElement = arrayString.first, firstElement.isLetter {
                return true
            }
        }
        
    }
    
    return false
}

print(CodelandUsernameValidation("aa_"))

func FindIntersection(_ strArr: [String]) -> String {
    
    let firstList = strArr[0]
        .split(separator: ",")
        .compactMap { Int($0.filter { !$0.isWhitespace }) }
    let secondList = strArr[1]
        .split(separator: ",")
        .compactMap { Int($0.filter { !$0.isWhitespace }) }

    let set1 = Set(firstList)
    let set2 = Set(secondList)
    let intersection = set1.intersection(set2).sorted()

    return intersection.isEmpty ? "false" : intersection.map { String($0) }.joined(separator: ",")
}

// Test cases
print(FindIntersection(["1, 3, 4, 7, 13", "1, 2, 4, 13, 15"]))
// Expected: 1,4,13

print(FindIntersection(["1, 3, 9, 10, 17, 18", "1, 4, 9, 10"]))
// Expected: 1,9,10

print(FindIntersection(["1, 5, 9", "2, 4, 6"]))
// Expected: false
