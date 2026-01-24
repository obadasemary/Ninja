import Foundation

/*:
 # Actors Bootcamp

 ## Overview
 This playground provides a comprehensive guide to Swift Actors and their role in safe concurrent programming.

 ## Topics Covered

 1. **The Problem: Data Races with Classes**
    - Demonstrating thread-safety issues with traditional classes
    - Understanding how concurrent access leads to data races

 2. **The Solution: Actors**
    - How actors provide automatic thread safety
    - Actor-isolated mutable state protection

 3. **Actor Isolation and Await**
    - Understanding when `await` is required
    - Internal vs external actor access patterns

 4. **MainActor for UI Updates**
    - Using `@MainActor` for main-thread operations
    - Ensuring UI updates happen on the main thread

 5. **Practical Example: Image Cache**
    - Building a thread-safe cache with actors
    - Real-world concurrent data management

 6. **Actor Reentrancy**
    - Understanding how actors can be reentered at await points
    - Managing state changes during suspension

 7. **Nonisolated Methods**
    - Creating actor methods that don't require await
    - Working with methods that don't access mutable state

 8. **Actor vs Class Comparison**
    - Key differences between actors and classes
    - When to use each type

 ## Key Concepts

 - **Actor**: A reference type that protects its mutable state from data races
 - **Actor Isolation**: The mechanism that ensures only one task accesses an actor at a time
 - **Reentrancy**: Actors can be suspended and resumed, allowing interleaving of operations
 - **MainActor**: A special global actor that runs code on the main thread
 - **Nonisolated**: Marks methods that don't access actor-isolated state

 ## Requirements
 - Swift 5.5+
 - Understanding of async/await and Swift Concurrency

 ---
 */

// MARK: - 1. THE PROBLEM: Data Races with Classes

print("=== 1. THE PROBLEM: Data Races with Classes ===\n")

/**
 A bank account implementation that is NOT thread-safe.

 This class demonstrates the classic data race problem when multiple threads
 access and modify shared mutable state without synchronization.

 ## Problem
 When multiple threads call `deposit()` or `withdraw()` concurrently, they can:
 1. Read the same `balance` value
 2. Perform their calculations
 3. Write back their results, overwriting each other's changes

 This leads to lost updates and incorrect balance values.

 - Warning: Do NOT use this pattern in production code. Use actors or other synchronization mechanisms instead.
 */
class UnsafeBankAccount {
    /// The current balance of the account. Not protected from concurrent access.
    var balance: Double = 0

    /**
     Deposits an amount into the account.

     - Parameter amount: The amount to deposit
     - Warning: Not thread-safe. Concurrent calls will cause data races.
     */
    func deposit(amount: Double) {
        let currentBalance = balance
        // Simulate some processing time
        Thread.sleep(forTimeInterval: 0.001)
        balance = currentBalance + amount
    }

    /**
     Withdraws an amount from the account.

     - Parameter amount: The amount to withdraw
     - Warning: Not thread-safe. Concurrent calls will cause data races.
     */
    func withdraw(amount: Double) {
        let currentBalance = balance
        Thread.sleep(forTimeInterval: 0.001)
        balance = currentBalance - amount
    }
}

// Demonstrating the data race problem
let unsafeAccount = UnsafeBankAccount()
unsafeAccount.balance = 1000

// Multiple concurrent deposits - should result in 1500, but might not due to race conditions
DispatchQueue.global().async {
    unsafeAccount.deposit(amount: 100)
}
DispatchQueue.global().async {
    unsafeAccount.deposit(amount: 200)
}
DispatchQueue.global().async {
    unsafeAccount.deposit(amount: 200)
}

// Wait to see the incorrect result
Thread.sleep(forTimeInterval: 0.1)
print("❌ Unsafe Account Balance: \(unsafeAccount.balance) (Expected: 1500, but got incorrect result due to data race)\n")


// MARK: - 2. THE SOLUTION: Actors Provide Thread Safety

print("=== 2. THE SOLUTION: Actors ===\n")

/**
 A thread-safe bank account implementation using Swift actors.

 This actor demonstrates how Swift's actor model automatically provides thread safety
 for mutable state without requiring manual synchronization.

 ## How It Works
 - The actor ensures only one task can access its mutable state at a time
 - Methods are serialized automatically by the Swift runtime
 - External callers must use `await` to access actor methods
 - Internal methods can access state directly without `await`

 ## Benefits
 - No data races (compiler enforced)
 - No manual locks or synchronization needed
 - Clean, readable concurrent code

 - Note: All mutable properties and methods are isolated to the actor by default.
 */
actor SafeBankAccount {
    /// The current balance of the account. Protected by actor isolation.
    var balance: Double = 0

    /**
     Deposits an amount into the account in a thread-safe manner.

     The actor ensures this method executes atomically relative to other
     actor methods, preventing data races.

     - Parameter amount: The amount to deposit
     - Note: External callers must use `await` to call this method.
     */
    func deposit(amount: Double) async {
        let currentBalance = balance
        // Simulate some processing time
        try? await Task.sleep(nanoseconds: 1_000_000) // 0.001 seconds
        balance = currentBalance + amount
    }

    /**
     Withdraws an amount from the account in a thread-safe manner.

     - Parameter amount: The amount to withdraw
     - Note: External callers must use `await` to call this method.
     */
    func withdraw(amount: Double) async {
        let currentBalance = balance
        try? await Task.sleep(nanoseconds: 1_000_000)
        balance = currentBalance - amount
    }

    /**
     Returns the current balance.

     - Returns: The current account balance
     - Note: This is a synchronous method but still requires `await` when called from outside the actor.
     */
    func getBalance() -> Double {
        return balance
    }
}

// Using the safe actor
Task {
    let safeAccount = SafeBankAccount()
    await safeAccount.deposit(amount: 1000)

    // Multiple concurrent deposits - will execute safely one at a time
    async let deposit1: () = safeAccount.deposit(amount: 100)
    async let deposit2: () = safeAccount.deposit(amount: 200)
    async let deposit3: () = safeAccount.deposit(amount: 200)

    await deposit1
    await deposit2
    await deposit3

    let finalBalance = await safeAccount.getBalance()
    print("✅ Safe Account Balance: \(finalBalance) (Correct: 1500)\n")
}


// MARK: - 3. Actor Isolation and Await

print("=== 3. Actor Isolation ===\n")

/**
 A simple counter actor demonstrating actor isolation rules.

 ## Actor Isolation Rules

 **Inside the actor (synchronous access):**
 - Methods can access `count` directly without `await`
 - Methods can call other actor methods without `await`
 - All mutable state is accessible synchronously

 **Outside the actor (asynchronous access):**
 - Must use `await` to call actor methods
 - Must use `await` to access actor properties
 - The compiler enforces this with compile-time errors

 This ensures that the actor's state is never accessed concurrently,
 preventing data races while maintaining a simple programming model.
 */
actor Counter {
    /// The current count value. Private and isolated to this actor.
    private var count = 0

    /**
     Increments the counter by 1.

     - Note: Inside the actor, can access `count` directly without `await`.
     */
    func increment() {
        count += 1  // No await needed inside the actor
        print("Count incremented to \(count)")
    }

    /**
     Decrements the counter by 1.
     */
    func decrement() {
        count -= 1
        print("Count decremented to \(count)")
    }

    /**
     Returns the current count value.

     - Returns: The current count
     - Note: Synchronous method, but requires `await` from external callers.
     */
    func getCount() -> Int {
        return count  // Direct access inside the actor
    }

    /**
     Resets the counter to 0.

     - Note: Can call other actor methods internally without `await`.
     */
    func reset() {
        count = 0
        print("Count reset to \(count)")
    }
}

Task {
    let counter = Counter()

    // Outside the actor, we must use await
    await counter.increment()
    await counter.increment()
    await counter.increment()

    let currentCount = await counter.getCount()
    print("Current count: \(currentCount)")

    await counter.reset()
    print()
}


// MARK: - 4. MainActor for UI Updates

print("=== 4. MainActor for UI Updates ===\n")

/**
 A view model that uses `@MainActor` to ensure all UI updates happen on the main thread.

 ## MainActor Overview
 - `@MainActor` is a global actor that represents the main thread
 - All properties and methods marked with `@MainActor` execute on the main thread
 - Essential for UIKit/AppKit code that requires main thread execution
 - Prevents common threading bugs in UI code

 ## Usage Patterns
 - Mark entire classes with `@MainActor` for view models and UI controllers
 - Mark individual methods/properties with `@MainActor` for selective main-thread execution
 - Use `Task { @MainActor in }` to switch to main thread in async context

 - Important: All UI framework calls (UIKit, AppKit, SwiftUI published properties) must be on the main thread.
 */
@MainActor
class ViewModel {
    /// The title displayed in the UI. Always accessed on the main thread.
    var title: String = "Loading..."

    /// Loading state indicator. Always accessed on the main thread.
    var isLoading: Bool = false

    /**
     Updates the title property.

     - Parameter newTitle: The new title to display
     - Note: Guaranteed to run on the main thread due to `@MainActor` on the class.
     */
    func updateTitle(_ newTitle: String) {
        // This will always run on the main thread
        title = newTitle
        print("Title updated on main thread: \(title)")
    }

    /**
     Fetches data asynchronously and updates the UI on the main thread.

     This demonstrates how to:
     - Run background work (network calls) off the main thread
     - Update UI properties on the main thread automatically

     - Note: Even though this is async, all property updates happen on the main thread
       because the entire class is marked `@MainActor`.
     */
    func fetchData() async {
        isLoading = true
        print("Fetching data...")

        // Simulate network call (this runs in background)
        await Task.detached {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }.value

        // UI update automatically on main thread since this is @MainActor
        isLoading = false
        title = "Data Loaded"
        print("Data fetched, UI updated on main thread")
    }
}

Task { @MainActor in
    let viewModel = ViewModel()
    await viewModel.fetchData()
    print()
}


// MARK: - 5. Practical Example: Image Cache

print("=== 5. Practical Example: Thread-Safe Image Cache ===\n")

/**
 A thread-safe image cache implementation using actors.

 ## Real-World Use Case
 Image caching is a common scenario where:
 - Multiple tasks may request the same image simultaneously
 - Images need to be cached to avoid redundant downloads
 - Cache updates must be thread-safe to prevent corruption

 ## Why Use an Actor
 - Multiple concurrent image downloads need safe cache access
 - Dictionary operations (read/write) must be serialized
 - No manual synchronization code needed

 ## Pattern
 This demonstrates the common pattern of wrapping a collection
 (Dictionary, Array, Set) in an actor to make it thread-safe.

 - Note: This pattern can be applied to any shared mutable data structure.
 */
actor ImageCache {
    /// The internal cache storage. Protected by actor isolation.
    private var cache: [String: Data] = [:]

    /**
     Retrieves cached image data for a given key.

     - Parameter key: The cache key (typically a URL or filename)
     - Returns: The cached image data, or `nil` if not found
     */
    func getImage(for key: String) -> Data? {
        return cache[key]
    }

    /**
     Stores image data in the cache.

     - Parameters:
       - data: The image data to cache
       - key: The cache key (typically a URL or filename)
     */
    func setImage(_ data: Data, for key: String) {
        cache[key] = data
        print("Cached image for key: \(key)")
    }

    /**
     Removes an image from the cache.

     - Parameter key: The cache key of the image to remove
     */
    func removeImage(for key: String) {
        cache[key] = nil
        print("Removed image for key: \(key)")
    }

    /**
     Clears all cached images.
     */
    func clearCache() {
        cache.removeAll()
        print("Cache cleared")
    }

    /**
     Returns the number of cached images.

     - Returns: The count of cached images
     */
    func cacheSize() -> Int {
        return cache.count
    }
}

Task {
    let imageCache = ImageCache()

    // Simulate caching images from multiple sources concurrently
    let imageData1 = Data([1, 2, 3])
    let imageData2 = Data([4, 5, 6])
    let imageData3 = Data([7, 8, 9])

    async let cache1: () = imageCache.setImage(imageData1, for: "profile.jpg")
    async let cache2: () = imageCache.setImage(imageData2, for: "header.jpg")
    async let cache3: () = imageCache.setImage(imageData3, for: "logo.jpg")

    await cache1
    await cache2
    await cache3

    let size = await imageCache.cacheSize()
    print("Total cached images: \(size)")

    if let image = await imageCache.getImage(for: "profile.jpg") {
        print("Retrieved image data: \(image)")
    }

    await imageCache.clearCache()
    print()
}


// MARK: - 6. Actor Reentrancy

print("=== 6. Actor Reentrancy ===\n")

/**
 A database manager demonstrating actor reentrancy.

 ## Actor Reentrancy Explained

 **What is Reentrancy?**
 - When an actor method suspends (at an `await` point), it releases the actor
 - Other tasks can then access the actor while the first task is suspended
 - When the first task resumes, the actor's state might have changed

 **Why Does This Matter?**
 - You cannot assume state is unchanged after an `await`
 - Multiple tasks can be interleaved within the actor
 - Need to revalidate assumptions after suspension points

 **Example:**
 ```swift
 func saveUser(name: String) async {
     connections.append(name)  // State snapshot 1
     await Task.sleep(...)     // ⚠️ Other tasks can run here
     // connections.count might have changed!
     print(connections.count)  // State snapshot 2 (different!)
 }
 ```

 - Warning: Always revalidate state assumptions after `await` points.
 */
actor DatabaseManager {
    /// Active database connections. May change during suspension points.
    private var connections: [String] = []

    /**
     Saves a user to the database with simulated async operation.

     Demonstrates reentrancy: the `connections` array can be modified by other
     tasks during the `await Task.sleep()` suspension point.

     - Parameter name: The user name to save
     - Note: The connection count printed may not match the count at the start
       of the method due to reentrancy.
     */
    func saveUser(name: String) async {
        print("Saving user: \(name)")
        connections.append(name)

        // This await point allows other tasks to access the actor
        await Task.sleep(1_000_000_000) // 1 second

        // After await, the state might have changed!
        print("User \(name) saved. Total connections: \(connections.count)")
    }

    /**
     Returns the current number of active connections.

     - Returns: The connection count
     */
    func getConnectionCount() -> Int {
        return connections.count
    }
}

Task {
    let db = DatabaseManager()

    // These will be interleaved due to reentrancy
    async let save1: () = db.saveUser(name: "Alice")
    async let save2: () = db.saveUser(name: "Bob")
    async let save3: () = db.saveUser(name: "Charlie")

    await save1
    await save2
    await save3

    let count = await db.getConnectionCount()
    print("Final connection count: \(count)\n")
}


// MARK: - 7. Nonisolated Methods

print("=== 7. Nonisolated Methods ===\n")

/**
 A user service demonstrating `nonisolated` methods.

 ## Nonisolated Methods Overview

 **What are Nonisolated Methods?**
 - Methods marked with `nonisolated` are not isolated to the actor
 - They can be called without `await`
 - They cannot access actor-isolated mutable state
 - They can access other nonisolated methods and properties

 **When to Use Nonisolated:**
 - Pure functions that don't need actor state
 - Validation logic
 - Utility methods
 - Methods that only work with parameters
 - Computed properties that don't access mutable state

 **Benefits:**
 - Improved performance (no actor serialization overhead)
 - Can be called synchronously
 - Clearer intent (signals no state access)

 - Note: Use `nonisolated` for methods that logically belong to the actor but don't need state access.
 */
actor UserService {
    /// The current number of users. Isolated to the actor.
    private var userCount = 0

    /**
     Validates an email address format.

     This is marked `nonisolated` because it:
     - Doesn't access actor state (`userCount`)
     - Is a pure function based only on parameters
     - Can be called without `await`

     - Parameter email: The email address to validate
     - Returns: `true` if the email contains an @ symbol, `false` otherwise
     - Note: Can be called synchronously, even from outside the actor.
     */
    nonisolated func validateEmail(_ email: String) -> Bool {
        // Cannot access userCount here (it's isolated to the actor)
        return email.contains("@")
    }

    /**
     Adds a user if their email is valid.

     Demonstrates calling a `nonisolated` method from within the actor
     without needing `await`.

     - Parameter email: The email address of the user to add
     */
    func addUser(email: String) {
        if validateEmail(email) {  // Can call nonisolated method without await
            userCount += 1
            print("User added. Total users: \(userCount)")
        } else {
            print("Invalid email: \(email)")
        }
    }
}

Task {
    let userService = UserService()

    // Nonisolated method - no await needed
    let isValid = userService.validateEmail("test@example.com")
    print("Email is valid: \(isValid)")

    // Regular actor method - await required
    await userService.addUser(email: "test@example.com")
    await userService.addUser(email: "invalid-email")
    print()
}


// MARK: - 8. Actor vs Class Comparison

/*:
 ## Summary: When to Use Actors vs Classes

 This section provides a comprehensive comparison between actors and classes,
 helping you decide which to use for your specific use case.

 ### Decision Guide
 - **Use Actors** when you have shared mutable state accessed concurrently
 - **Use Classes** when you don't need thread safety or when you need inheritance
 - **Use Structs** when you have value semantics and no need for shared state
 */

print("=== 8. Actor vs Class Summary ===\n")

print("""
CLASS:
- Reference type
- Can be subclassed
- NOT thread-safe by default
- No await required to access properties/methods
- Can have data races with concurrent access
- Need manual synchronization (locks, queues)

ACTOR:
- Reference type
- CANNOT be subclassed
- Thread-safe by default
- Await required for external access
- No data races - compiler enforced
- Automatic synchronization
- Can be reentered during await points

WHEN TO USE ACTORS:
✅ Shared mutable state accessed from multiple tasks
✅ Concurrent operations on the same data
✅ Replacing manual synchronization (locks, queues)
✅ Network services, caches, databases
✅ Any state that needs thread safety

WHEN TO USE CLASSES:
✅ No concurrent access needed
✅ Need inheritance
✅ UI components (use @MainActor instead)
✅ No mutable state (though structs might be better)
""")

print("\n=== End of Actors Bootcamp ===")

/*:
 ---

 ## Key Takeaways

 1. **Actors solve data races** by providing compile-time guarantees about concurrent access
 2. **Use `await` for external access**, but not for internal actor methods
 3. **MainActor ensures UI updates** happen on the main thread
 4. **Actor reentrancy** means state can change during suspension points
 5. **Nonisolated methods** provide synchronous access for stateless operations
 6. **Choose actors for concurrent access** to shared mutable state

 ## Best Practices

 - ✅ Use actors for services, caches, and shared resources
 - ✅ Mark UI code with `@MainActor` to ensure main-thread execution
 - ✅ Be aware of reentrancy at `await` points
 - ✅ Use `nonisolated` for pure functions and validation
 - ✅ Prefer actors over manual synchronization (locks, queues)
 - ❌ Don't use actors when you don't need thread safety
 - ❌ Don't assume state is unchanged after `await`
 - ❌ Don't use actors when you need inheritance (consider composition)

 ## Further Reading

 - [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
 - [SE-0306: Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0306-actors.md)
 - [SE-0316: Global Actors](https://github.com/apple/swift-evolution/blob/main/proposals/0316-global-actors.md)

 ---
 */
