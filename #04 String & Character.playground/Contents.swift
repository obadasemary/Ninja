import Foundation

var greeting = "Hello, playground"

var singleLineComment = "Hello, World!"
print(singleLineComment)

let multipleLineComment = """
    This is a 
    multi line comment
    """
print(multipleLineComment)

let longComment: String = """
This is a long comment that spans multiple lines and uses special characters like.
"""
print(longComment)

let specialCharacters = "This is a qoute: \"Hello, World!\"."
print(specialCharacters)

let usingHash = #"This "a" string"#
print(usingHash)

let newLineTab = "Hello\nWorld\tTab"
print(newLineTab)

var emptyString: String = ""
var emptyString2: String = String()

print("Empty String Values: \(emptyString), Empty String2 Values: \(emptyString2)")

var multipleStrings: String = "Hello, World!"
print("Multiple Strings: \(multipleStrings)")
multipleStrings += ", How are you?"
print("Updated Multiple Strings: \(multipleStrings)")

let part1 = "Hello"
let part2 = ", World!"
let concatenatedString = part1 + part2
print("Concatenated String: \(concatenatedString)")

let character: Character = "H"
print("Character: \(character)")
let charArray: [Character] = ["H", "e", "l", "l", "o"]
print("Character Array: \(charArray)")
let charToString = String(charArray)
print("Character Array as String: \(charToString)")

for char in "Swift is fun!" {
    print("Character: \(char)")
}

let text = "Hello, World!"
let firstCharacter = text[text.startIndex]
print(firstCharacter)
let lastCharacter = text[text.index(before: text.endIndex)]
print(lastCharacter)

var insertString = "Hello"
insertString
    .insert("!", at: insertString.endIndex)
print(insertString)
insertString.remove(at: insertString.index(before: insertString.endIndex))
print(insertString)

print("Inserted String: \(insertString)")

let fullString: String = "Hello, World!"
let subString = fullString.prefix(5)

let hasPrefix = fullString.hasPrefix("Hello")
let hasSuffix = fullString.hasSuffix("!")

let unicodeStrign = "🌍"
print(unicodeStrign)
