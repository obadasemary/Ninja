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

struct MyStruct {
    var text: String
}

class MyClass {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    func updateText(to newText: String) {
        self.text = newText
    }
}

actor MyActor {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    func updateText(to newText: String) {
        self.text = newText
    }
}

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

struct CustomStruct {
    let text: String
    
    func updateText(to newText: String) -> CustomStruct {
        CustomStruct(text: newText)
    }
}

struct MutatingStruct {
    private(set) var text: String
    
    init(text: String) {
        self.text = text
    }
    
    mutating func updateText(to newText: String) {
        self.text = newText
    }
}

private extension StructClassActorBootcamp {
    
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
