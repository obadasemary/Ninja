/*

 VALUE TYPES VS REFERENCE TYPES
 ================================

 VALUE TYPES:
 ------------
 - Stored in Stack memory
 - When copied, a new independent copy is created
 - Changes to the copy do NOT affect the original
 - Thread-safe by default (each thread gets its own copy)
 - Examples: Struct, Enum, Tuple
 - Swift's standard types are value types: Int, String, Array, Dictionary, Set

 Key Characteristics:
 • Copy-on-assignment: var b = a creates a new copy
 • Faster allocation/deallocation (stack memory)
 • No memory leaks or retain cycles
 • Predictable behavior in concurrent code
 • Use 'mutating' keyword to modify properties in methods

 REFERENCE TYPES:
 ----------------
 - Stored in Heap memory
 - When copied, only the reference (pointer) is copied
 - Multiple variables can point to the same instance
 - Changes through any reference affect all references
 - Examples: Class, Actor, Closure
 - Requires memory management (ARC - Automatic Reference Counting)

 Key Characteristics:
 • Copy-on-assignment: var b = a creates a new reference to same instance
 • Slower allocation/deallocation (heap memory)
 • Can have retain cycles (use weak/unowned references)
 • Requires synchronization for thread safety
 • Can modify properties through 'let' constant references
 • Supports inheritance and polymorphism

 WHEN TO USE WHICH?
 ------------------
 Use VALUE TYPES (Struct) when:
 • Data represents a simple value or collection of values
 • You want independent copies when passing around
 • Equality means "same values" (use Equatable)
 • You need thread-safety without locks
 • Default Swift choice for most data models

 Use REFERENCE TYPES (Class) when:
 • You need a shared, mutable state
 • You need inheritance or polymorphism
 • Identity matters more than equality (=== vs ==)
 • Working with Objective-C APIs
 • Implementing delegation patterns

 Use ACTOR when:
 • You need a reference type with built-in thread-safety
 • Managing shared mutable state in concurrent code
 • Protecting data from race conditions
 • Each actor has its own serial executor
 • Swift 5.5+ concurrency feature

 MEMORY BEHAVIOR:
 ----------------
 Value Type (Struct):
   var a = MyStruct()  // Stored in stack
   var b = a           // New copy created in stack
   b.modify()          // Only b is affected

 Reference Type (Class):
   let a = MyClass()   // Instance in heap, reference in stack
   let b = a           // New reference to same heap instance
   b.modify()          // Both a and b see the change

 Actor (Reference Type with Actor Isolation):
   let a = MyActor()   // Instance in heap with serial executor
   let b = a           // New reference to same heap instance
   await b.modify()    // Serialized access, thread-safe

 STRUCT MUTATION PATTERNS:
 -------------------------
 1. Mutable Properties (var):
    - Direct property mutation on var instances
    - Simple but allows unrestricted mutation

 2. Immutable with Copy (CustomStruct):
    - All properties are 'let' constants
    - Update methods return new instances
    - Functional programming style
    - Guarantees immutability

 3. Mutating Methods (MutatingStruct):
    - Use 'mutating' keyword for methods that change state
    - Properties can be private(set) for controlled mutation
    - Clear API that shows which methods modify state
    - Best practice for value types

 ACTOR ISOLATION:
 ----------------
 Actors protect their mutable state through:
 • Actor isolation: only one task can access mutable state at a time
 • All property access requires 'await' from outside the actor
 • Methods are implicitly async when accessing isolated state
 • Prevents data races at compile time
 • Each actor has its own serial executor for sequential access

 COMMON PITFALLS:
 ----------------
 Structs:
 • Forgetting 'mutating' keyword on methods that modify properties
 • Unnecessary copies in performance-critical code
 • Large structs can be expensive to copy

 Classes:
 • Retain cycles with closures and delegates (use weak/unowned)
 • Unexpected shared state mutations
 • Thread safety issues in concurrent code
 • Memory leaks from circular references

 Actors:
 • Forgetting 'await' when accessing properties from outside
 • Actor reentrancy can cause unexpected state changes
 • Not suitable for synchronous APIs
 • Cannot subclass or use inheritance

*/

import Foundation

var greeting = "Hello, playground"

struct StructClassActorBootcamp {
    
    func start() {
        runTest()
    }
}

let x = StructClassActorBootcamp()
x.start()

// MARK: - Basic Value Type Example

/// Simple struct demonstrating value type behavior
/// - Properties are mutable via 'var'
/// - Copying creates an independent instance
/// - Changes to copy don't affect original
struct MyStruct {
    var text: String
}

// MARK: - Basic Reference Type Example

/// Simple class demonstrating reference type behavior
/// - Stored in heap memory
/// - Copying shares the same instance
/// - Changes through any reference affect all references
/// - Can modify properties even when instance is declared with 'let'
class MyClass {
    var text: String

    init(text: String) {
        self.text = text
    }

    func updateText(to newText: String) {
        self.text = newText
    }
}

// MARK: - Actor Example (Thread-Safe Reference Type)

/// Actor demonstrating thread-safe reference type behavior
/// - Reference type like class, but with actor isolation
/// - Property access from outside requires 'await'
/// - Serialized access prevents data races
/// - Only one task can access mutable state at a time
actor MyActor {
    var text: String

    init(text: String) {
        self.text = text
    }

    func updateText(to newText: String) {
        self.text = newText
    }
}

// MARK: - Test Functions

private extension StructClassActorBootcamp {

    func runTest() {
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        actorTest1()
        printDivider()
        structTest2()
        printDivider()
        classTest2()
    }

    func printDivider() {
        print("""

            -----------------------------------

            """)
    }

    /// Demonstrates VALUE TYPE behavior (Struct)
    /// - Creates objectA with initial text
    /// - Copies objectA to objectB (creates independent copy)
    /// - Modifies objectB
    /// - Shows that objectA remains unchanged (independent copy)
    ///
    /// Expected Output: objectA keeps "strating title!", objectB has "changed title!"
    func structTest1() {
        print("structTest1 started! \n")
        let objectA = MyStruct(text: "strating title!")
        print("Object A: \(objectA.text)")

        print("Pass the VALUES of objectA to objectB")
        var objectB = objectA
        print("Object B: \(objectB.text)")

        objectB.text = "changed title!"
        print("Object B: title changed")

        print("Object A: \(objectA.text)")
        print("Object B: \(objectB.text)")
    }

    /// Demonstrates REFERENCE TYPE behavior (Class)
    /// - Creates objectA with initial text
    /// - Assigns objectA to objectB (copies reference, not value)
    /// - Modifies objectB
    /// - Shows that BOTH objectA and objectB reflect the change (shared instance)
    ///
    /// Expected Output: BOTH objectA and objectB have "changed title!"
    func classTest1() {
        print("classTest1 started! \n")
        let objectA = MyClass(text: "strating title!")
        print("Object A: \(objectA.text)")

        print("Pass the REFERENCES of objectA to objectB")
        let objectB = objectA
        print("Object B: \(objectB.text)")

        objectB.text = "changed title!"
        print("Object B: title changed")

        print("Object A: \(objectA.text)")
        print("Object B: \(objectB.text)")
    }

    /// Demonstrates ACTOR behavior (Reference Type with Actor Isolation)
    /// - Creates actorA with initial text
    /// - Assigns actorA to actorB (copies reference like class)
    /// - Modifies actorB using await (serialized access)
    /// - Shows that BOTH actorA and actorB reflect the change (shared instance)
    /// - Note: All property access requires 'await' from outside the actor
    ///
    /// Expected Output: BOTH actorA and actorB have "changed title!"
    /// Key Difference from Class: Access is serialized and thread-safe
    func actorTest1() {
        Task {
            print("actorTest1 started! \n")
            let actorA = MyActor(text: "strating title!")
            await print("Actor A: \(actorA.text)")

            print("Pass the REFERENCES of objectA to objectB")
            let actorB = actorA
            await print("Actor B: \(actorB.text)")

            await actorB.updateText(to: "changed title!")
            print("Actor B: title changed")

            await print("Object A: \(actorA.text)")
            await print("Object B: \(actorB.text)")
        }
    }
}

// MARK: - Immutable Struct Pattern

/// Immutable struct pattern - functional programming approach
/// - All properties are 'let' constants (immutable)
/// - Update methods return NEW instances instead of modifying existing
/// - Guarantees immutability and thread safety
/// - Similar to how Swift's String and Array work internally
/// - Good for: Functional programming, avoiding side effects, value semantics
struct CustomStruct {
    let text: String

    /// Returns a new instance with updated text
    /// Original instance remains unchanged
    func updateText(to newText: String) -> CustomStruct {
        CustomStruct(text: newText)
    }
}

// MARK: - Mutating Struct Pattern (Best Practice)

/// Mutating struct pattern - controlled mutation
/// - Properties are private(set) for read-only external access
/// - Uses 'mutating' keyword for methods that modify state
/// - Clear API that shows which methods change state
/// - Best practice for value types in Swift
/// - Good for: Clear mutation semantics, encapsulation, safety
struct MutatingStruct {
    private(set) var text: String

    init(text: String) {
        self.text = text
    }

    /// Mutates the current instance in-place
    /// Requires 'var' declaration to call this method
    mutating func updateText(to newText: String) {
        self.text = newText
    }
}

private extension StructClassActorBootcamp {

    /// Demonstrates different STRUCT MUTATION PATTERNS
    ///
    /// Pattern 1: MyStruct - Direct property mutation (var property)
    /// - Simple mutable property approach
    /// - Direct assignment: struct1.text = "new value"
    /// - Requires 'var' instance
    ///
    /// Pattern 2: CustomStruct - Immutable replacement (let property)
    /// - All properties are immutable ('let')
    /// - Create new instance: struct2 = CustomStruct(text: "new value")
    /// - Functional programming style
    ///
    /// Pattern 3: CustomStruct with helper - Immutable with update method
    /// - Same as Pattern 2, but with convenience method
    /// - Returns new instance: struct3 = struct3.updateText(to: "new value")
    /// - Clean API for creating modified copies
    ///
    /// Pattern 4: MutatingStruct - Controlled mutation (mutating keyword)
    /// - Best practice for value types
    /// - Private(set) properties with mutating methods
    /// - Clear API: struct4.updateText(to: "new value")
    /// - Encapsulation and controlled state changes
    func structTest2() {
        print("structTest 2 !\n")

        var struct1 = MyStruct(text: "Title 1")
        print("Struct 1: ", struct1.text)
        struct1.text = "Title 2"
        print("Struct 1: ", struct1.text)

        var struct2 = CustomStruct(text: "Title 1")
        print("Struct 2: ", struct2.text)

        struct2 = CustomStruct(text: "Title 2")
        print("Struct 2: ", struct2.text)

        var struct3 = CustomStruct(text: "Title 1")
        print("Struct 3: ", struct3.text)
        struct3 = struct3.updateText(to: "Title 2")
        print("Struct 3: ", struct3.text)

        var struct4 = MutatingStruct(text: "Title 1")
        print("Struct 4: ", struct4.text)
        struct4.updateText(to: "Title 2")
        print("Struct 4: ", struct4.text)
    }
}

private extension StructClassActorBootcamp {

    /// Demonstrates CLASS (reference type) mutation behavior
    ///
    /// Key Points:
    /// 1. Can mutate properties even when declared with 'let'
    ///    - 'let' means the reference is constant (can't reassign to different instance)
    ///    - But the instance's properties can still be modified
    ///
    /// 2. Direct property access
    ///    - class1.text = "Title 2" (direct mutation)
    ///
    /// 3. Method-based mutation
    ///    - class2.updateText(to: "Title 2") (encapsulated mutation)
    ///
    /// 4. Shared reference behavior
    ///    - class3 = class2 creates another reference to same instance
    ///    - Modifying through class3 affects class2 (they're the same object)
    ///    - Both references see "Title 3" after class3.updateText()
    ///
    /// This demonstrates why classes need careful consideration for:
    /// - Thread safety (multiple references can modify simultaneously)
    /// - Unexpected mutations (changes through one reference affect all)
    /// - Memory management (retain cycles with strong references)
    func classTest2() {
        print("classTest 2 !\n")

        let class1 = MyClass(text: "Title 1")
        print("Class 1: ", class1.text)
        class1.text = "Title 2"
        print("Class 1: ", class1.text)

        let class2 = MyClass(text: "Title 1")
        print("Class 2: ", class2.text)
        class2.updateText(to: "Title 2")
        print("Class 2: ", class2.text)

        let class3 = class2
        print("Class 2: ", class2.text)
        print("Class 3: ", class3.text)
        class3.updateText(to: "Title 3")
        print("Class 2: ", class2.text)
        print("Class 3: ", class3.text)
    }
}
