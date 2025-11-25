import Foundation

var greeting = "Hello, playground"

var x = 10

let sum = 10 + 20
let difference = 20 - 10
let product = 10 * 20
let quotient = 20 / 10
let division = 20.0 / 10.0

let remainder = 9 % 4

let positiveNumber = +10.0
let negativeNumber = -10.0

var counter = 10

counter += 1
counter -= 1
counter *= 2
counter /= 2

let isEqual = 10 == 10
let isNotEqual = 10 != 20
let isGreaterThan = 10 > 20
let isLessThan = 10 < 20
let isGreaterThanOrEqualTo = 10 >= 20
let isLessThanOrEqualTo = 10 <= 20

let age = 18
let canVote = age >= 18 ? "Yes" : "No"

let closedRange = 1...5
let openRange = 1..<5
let numbers = [1, 2, 3, 4, 5]
let slice = numbers[2...]
let slice2 = numbers[..<3]

let isTrue = true
let isFalse = false

let notTrue = !isTrue
let andResult = isTrue && isFalse
let orResult = isTrue || isFalse

let complexCondition = (5 > 3) && ((2 + 2) == 4)
