# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Swift learning and practice repository containing multiple Xcode Playground files. Each playground focuses on different Swift concepts, algorithms, or coding challenges.

## Project Structure

The repository contains standalone Xcode Playground files organized by topic:

- **Tutorial Playgrounds** (numbered with #): Basic Swift concepts and language features
  - `#01 Constants & Variables.playground` - Variable declarations, constants, and type annotations
  - `#02 Print & Comment.playground` - Print statements, string interpolation, comments
  - `#03 Operators.playground` - Arithmetic, assignment, and basic operators
  - `#04 String & Character.playground` - String manipulation and character operations
  - `#05 Array.playground` - Array creation, manipulation, and operations
  - `#06 Set.playground` - Set operations and collections
  - `#07 Dictionary.playground` - Dictionary creation and key-value operations
  - `#08 Loops.playground` - For-in loops, while loops, and iteration patterns
  - `#09 Conditional Statements.playground` - If-else, switch statements, and control flow
  - `#10 Control Transfer Statements.playground` - Break, continue, fallthrough, and guard
  - `#33 Nested Types.playground` - Nested types and type organization

- **Advanced Concepts Playgrounds**: Protocol-oriented programming and architecture patterns
  - `ProtocolsBootcamp.playground` - Protocol definitions, extensions, and protocol-oriented design
  - `StructClassActorBootcamp.playground` - Struct vs Class vs Actor, value/reference types, and concurrency

- **Practice Playgrounds**: Algorithm and coding challenge implementations
  - `Ninja.playground` - Username validation and set intersection algorithms
  - `coderbyte.playground` - Cache implementation and JSON data parsing challenges
  - `Count Elements Greater Than Previous Average.playground` - Array processing algorithm
  - `FetchNextPage.playground` - Pagination and data fetching patterns
  - `Sezzle Inc.playground` - Company-specific coding challenges

- **UIKit Playgrounds**: iOS development and UI implementation
  - `Yassir.playground` - UIKit networking with URLSession and async image loading
  - `MyPlayground.playground` - Protocol/extension patterns and UIKit components

## Working with Xcode Playgrounds

### Opening Playgrounds

To work with a playground file:
```bash
open "playground-name.playground"
```

This will launch Xcode with the playground. Playgrounds execute immediately and show results inline.

### Playground Structure

Each playground contains:

- `Contents.swift` - Main executable code
- `contents.xcplayground` - Playground metadata
- `playground.xcworkspace/` - Xcode workspace data

### Editing Playground Files

When modifying playground code, directly edit the `Contents.swift` file within the `.playground` bundle:

```bash
# Example path
"#01 Constants & Variables.playground/Contents.swift"
```

## Code Patterns

### UIKit Playgrounds

Several playgrounds (`Yassir.playground`, `MyPlayground.playground`) demonstrate UIKit concepts:

- Use `PlaygroundSupport` framework for live views
- Set `PlaygroundPage.current.liveView` to display UI
- Implement async operations with `DispatchQueue` and `URLSession`

### Algorithm Challenges

Practice playgrounds (`coderbyte.playground`, `Ninja.playground`) follow this pattern:

- Implement solution as class methods or standalone functions
- Include test cases with expected outputs
- Use `print()` statements to verify results

## Git Status

The repository currently has staged and modified playground files. When committing changes:

- Group related playground updates together
- Use descriptive commit messages indicating the topic (e.g., "Add operators playground")
- Commit each logical unit of learning separately
