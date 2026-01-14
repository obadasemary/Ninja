# Ninja - Swift Learning & Practice Repository

A collection of Swift Xcode Playgrounds focused on learning Swift fundamentals, algorithms, and iOS development concepts.

## Overview

This repository contains multiple Xcode Playground files that cover various Swift concepts, from basic language features to advanced UIKit implementations and algorithmic challenges. Each playground is self-contained and can be executed independently.

## Repository Structure

### Tutorial Playgrounds

Basic Swift concepts for beginners:

- **[#01 Constants & Variables.playground](#01-constants--variablesplayground)** - Variable declarations, constants, and type annotations
- **[#02 Print & Comment.playground](#02-print--commentplayground)** - Print statements, string interpolation, and comments
- **[#03 Operators.playground](#03-operatorsplayground)** - Arithmetic, assignment, and basic operators

### Practice Playgrounds

Algorithm implementations and coding challenges:

- **[Ninja.playground](Ninja.playground)** - Username validation and set intersection algorithms
- **[coderbyte.playground](coderbyte.playground)** - Cache implementation and JSON data parsing challenges
- **[Yassir.playground](Yassir.playground)** - UIKit networking with URLSession and async image loading
- **[MyPlayground.playground](MyPlayground.playground)** - Protocol/extension patterns and UIKit components
- **[Count Elements Greater Than Previous Average.playground](Count%20Elements%20Greater%20Than%20Previous%20Average.playground)** - Array processing algorithm
- **[StructClassActorBootcamp.playground](StructClassActorBootcamp.playground)** - Swift concurrency concepts with struct, class, and actor comparisons

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

```
playground-name.playground/
├── Contents.swift              # Main executable code
├── contents.xcplayground       # Playground metadata
└── playground.xcworkspace/     # Xcode workspace data
```

## Code Patterns

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

1. Start with numbered tutorial playgrounds (#01, #02, #03)
2. Explore algorithm challenges (Ninja, coderbyte)
3. Study UIKit implementations (Yassir, MyPlayground)
4. Deep dive into concurrency (StructClassActorBootcamp)

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
