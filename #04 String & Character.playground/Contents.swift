// #04 String & Character
//
// Strings are collections of characters in Swift, used to represent text.
// Characters are single letter, number, symbol, or emoji.
//
// Key characteristics of Strings:
// - Unicode-compliant: Supports characters from any language including emojis
// - Value type: Strings are copied when assigned or passed to functions
// - Mutable: Can modify strings declared with var
// - String interpolation: Embed values inside strings using \()
//
// Key characteristics of Characters:
// - Represents a single extended grapheme cluster
// - Can be a letter, number, symbol, emoji, or combining characters
// - Type annotation required when declaring standalone character

import Foundation

// MARK: - String Literals

// Single-line string
var singleLineString = "Hello, World!"
print(singleLineString)

// Multi-line string using triple quotes
// Preserves formatting and line breaks
let multipleLineString = """
    This is a
    multi line string
    """
print(multipleLineString)

// Multi-line string without extra indentation
let longString: String = """
This is a long string that spans multiple lines and uses special characters.
"""
print(longString)

// MARK: - Special Characters and Escaping

// Escape special characters using backslash
let specialCharacters = "This is a quote: \"Hello, World!\"."
print(specialCharacters)

// Raw strings using # delimiters
// No need to escape quotes inside the string
let usingHash = #"This "a" string"#
print(usingHash)

// Escape sequences for newlines and tabs
let newLineTab = "Hello\nWorld\tTab"
print(newLineTab)

// MARK: - Creating Empty Strings

// Empty string using string literal
var emptyString: String = ""

// Empty string using String initializer
var emptyString2: String = String()

print("Empty String Values: \(emptyString), Empty String2 Values: \(emptyString2)")

// Check if a string is empty
print("Is emptyString empty? \(emptyString.isEmpty)")

// MARK: - String Mutability and Concatenation

// Mutable string (declared with var)
var mutableString: String = "Hello, World!"
print("Original String: \(mutableString)")

// Append to string using += operator
mutableString += ", How are you?"
print("Updated String: \(mutableString)")

// Concatenate strings using + operator
let part1 = "Hello"
let part2 = ", World!"
let concatenatedString = part1 + part2
print("Concatenated String: \(concatenatedString)")

// String interpolation - embed values in strings
let name = "Swift"
let version = 5
let message = "Welcome to \(name) version \(version)!"
print(message)

// MARK: - Working with Characters

// Character type requires explicit type annotation
let character: Character = "H"
print("Character: \(character)")

// Array of characters
let charArray: [Character] = ["H", "e", "l", "l", "o"]
print("Character Array: \(charArray)")

// Convert character array to string
let charToString = String(charArray)
print("Character Array as String: \(charToString)")

// MARK: - Iterating Over String Characters

// Iterate through each character in a string
print("\nIterating over string characters:")
for char in "Swift is fun!" {
    print("Character: \(char)")
}

// MARK: - String Indexing
// Swift strings use String.Index instead of integers for indexing
// This is because Swift characters can have different byte sizes (Unicode)

let text = "Hello, World!"

// Access first character using startIndex
let firstCharacter = text[text.startIndex]  // "H"
print("First character: \(firstCharacter)")

// Access last character (endIndex is AFTER the last character)
let lastCharacter = text[text.index(before: text.endIndex)]  // "!"
print("Last character: \(lastCharacter)")

// Access character at offset from start
let thirdCharacter = text[text.index(text.startIndex, offsetBy: 2)]  // "l"
print("Third character: \(thirdCharacter)")

// MARK: - Modifying Strings

// Insert character at specific index
var insertString = "Hello"
insertString.insert("!", at: insertString.endIndex)
print("After inserting '!': \(insertString)")

// Remove character at specific index
insertString.remove(at: insertString.index(before: insertString.endIndex))
print("After removing last character: \(insertString)")

// Append character to string
insertString.append("!")
print("After appending '!': \(insertString)")

// MARK: - Substrings and String Methods

let fullString: String = "Hello, World!"

// Get prefix (first N characters)
let subString = fullString.prefix(5)  // "Hello"
print("\nPrefix (first 5 chars): \(subString)")

// Get suffix (last N characters)
let suffixString = fullString.suffix(6)  // "World!"
print("Suffix (last 6 chars): \(suffixString)")

// Check if string starts with specific prefix
let hasPrefix = fullString.hasPrefix("Hello")
print("Starts with 'Hello'? \(hasPrefix)")

// Check if string ends with specific suffix
let hasSuffix = fullString.hasSuffix("!")
print("Ends with '!'? \(hasSuffix)")

// MARK: - Common String Operations

// Convert to uppercase/lowercase
let original = "Hello, World!"
print("\nOriginal: \(original)")
print("Uppercase: \(original.uppercased())")
print("Lowercase: \(original.lowercased())")

// Count characters in string
print("Character count: \(original.count)")

// Split string into array
let sentence = "Swift is awesome"
let words = sentence.split(separator: " ")
print("\nWords: \(words)")

// Replace occurrences
let textWithSpaces = "Hello World"
let replacedText = textWithSpaces.replacingOccurrences(of: " ", with: "-")
print("Replaced: \(replacedText)")

// MARK: - Unicode and Emoji Support

// Swift strings fully support Unicode characters and emojis
let unicodeString = "🌍"
print("\nUnicode emoji: \(unicodeString)")

let emojiString = "Hello 👋 Swift 🚀"
print("String with emojis: \(emojiString)")
print("Character count (including emojis): \(emojiString.count)")

// Unicode scalars
let heart = "\u{1F496}"  // 💖
print("Heart emoji from Unicode scalar: \(heart)")
