# Ninja - Swift Learning & Practice Repository

A collection of Swift Xcode Playgrounds focused on learning Swift fundamentals, algorithms, and iOS development concepts.

## Overview

This repository contains multiple Xcode Playground files that cover various Swift concepts, from basic language features to advanced UIKit implementations and algorithmic challenges. Each playground is self-contained and can be executed independently.

## Repository Structure

### Tutorial Playgrounds

Basic Swift concepts and language features:

- **[#01 Constants & Variables.playground](%2301%20Constants%20%26%20Variables.playground)** - Variable declarations, constants, and type annotations
- **[#02 Print & Comment.playground](%2302%20Print%20%26%20Comment.playground)** - Print statements, string interpolation, and comments
- **[#03 Operators.playground](%2303%20Operators.playground)** - Arithmetic, assignment, and basic operators
- **[#04 String & Character.playground](%2304%20String%20%26%20Character.playground)** - String manipulation and character operations
- **[#05 Array.playground](%2305%20Array.playground)** - Array creation, manipulation, and operations
- **[#06 Set.playground](%2306%20Set.playground)** - Set operations and collections
- **[#07 Dictionary.playground](%2307%20Dictionary.playground)** - Dictionary creation and key-value operations
- **[#08 Loops.playground](%2308%20Loops.playground)** - For-in loops, while loops, and iteration patterns
- **[#09 Conditional Statements.playground](%2309%20Conditional%20Statements.playground)** - If-else, switch statements, and control flow
- **[#10 Control Transfer Statements.playground](%2310%20Control%20Transfer%20Statements.playground)** - Break, continue, fallthrough, and guard
- **[#33 Nested Types.playground](%2333%20Nested%20Types.playground)** - Nested types and type organization

### Advanced Concepts Playgrounds

Protocol-oriented programming and architecture patterns:

- **[ProtocolsBootcamp.playground](ProtocolsBootcamp.playground)** - Protocol definitions, extensions, and protocol-oriented design
- **[StructClassActorBootcamp.playground](StructClassActorBootcamp.playground)** - Struct vs Class vs Actor, value/reference types, and concurrency
- **[NetworkingArchitecture.playground](NetworkingArchitecture.playground)** - Clean Architecture networking with Repository pattern, three async patterns (Completion Handlers, Combine, Async/Await), error handling, dependency injection, and comprehensive unit tests

### Practice Playgrounds

Algorithm implementations and coding challenges:

- **[Ninja.playground](Ninja.playground)** - Username validation and set intersection algorithms
- **[coderbyte.playground](coderbyte.playground)** - Cache implementation and JSON data parsing challenges
- **[Count Elements Greater Than Previous Average.playground](Count%20Elements%20Greater%20Than%20Previous%20Average.playground)** - Array processing algorithm
- **[FetchNextPage.playground](FetchNextPage.playground)** - Pagination and data fetching patterns
- **[Sezzle Inc.playground](Sezzle%20Inc.playground)** - Company-specific coding challenges

### UIKit Playgrounds

iOS development and UI implementation:

- **[Yassir.playground](Yassir.playground)** - UIKit networking with URLSession and async image loading
- **[MyPlayground.playground](MyPlayground.playground)** - Protocol/extension patterns and UIKit components

## Getting Started

### Prerequisites

- macOS with Xcode installed
- Xcode 14.0 or later recommended
- Basic understanding of Swift (for practice playgrounds)

### Opening a Playground

You can open any playground file directly from Finder or using the command line:

```bash
open "playground-name.playground"
```

For example:

```bash
open "#01 Constants & Variables.playground"
open "Ninja.playground"
```

Xcode will launch and the playground will execute automatically, showing results inline.

### Using Xcode Workspace

You can also open the entire workspace to access all playgrounds:

```bash
open Ninja.xcworkspace
```

## Playground Structure

Each playground contains:

```text
playground-name.playground/
├── Contents.swift              # Main executable code
├── contents.xcplayground       # Playground metadata
└── playground.xcworkspace/     # Xcode workspace data
```

## Common Patterns

### UIKit Playgrounds

Playgrounds like [Yassir.playground](Yassir.playground) and [MyPlayground.playground](MyPlayground.playground) demonstrate UIKit concepts:

```swift
import PlaygroundSupport
import UIKit

// Set up live view
let viewController = CustomViewController()
PlaygroundPage.current.liveView = viewController
```

Features demonstrated:
- Live view rendering
- Async operations with `DispatchQueue`
- URLSession networking
- Custom UI components

### Algorithm Challenges

Practice playgrounds follow a test-driven pattern:

```swift
// Implement solution
func solution(_ input: String) -> String {
    // Implementation
}

// Test cases
print(solution("test"))  // Expected output
```

## Learning Path

Recommended order for beginners:

1. **Swift Fundamentals** - Start with numbered tutorial playgrounds (#01-#10) to learn basic syntax and language features
2. **Advanced Swift** - Study advanced concepts like nested types (#33) and protocol-oriented programming (ProtocolsBootcamp)
3. **Type Systems & Concurrency** - Understand value vs reference types and actors (StructClassActorBootcamp)
4. **Algorithm Practice** - Solve coding challenges (Ninja, coderbyte, FetchNextPage)
5. **iOS Development** - Explore UIKit and networking (Yassir, MyPlayground)

## Contributing

This is a personal learning repository, but feel free to:
- Fork and create your own playground collection
- Suggest improvements via issues
- Share your own learning resources

## License

This project is for educational purposes.

## Resources

- [Swift Programming Language Guide](https://docs.swift.org/swift-book/)
- [Swift by Sundell](https://www.swiftbysundell.com/)
- [Ray Wenderlich Tutorials](https://www.raywenderlich.com/)
- [Hacking with Swift](https://www.hackingwithswift.com/)
