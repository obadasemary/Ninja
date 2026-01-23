import Foundation

// MARK: - 1. THE PROBLEM: Data Races with Classes

print("=== 1. THE PROBLEM: Data Races with Classes ===\n")

// This class is NOT thread-safe - multiple threads can access and modify the balance simultaneously
class UnsafeBankAccount {
    var balance: Double = 0

    func deposit(amount: Double) {
        let currentBalance = balance
        // Simulate some processing time
        Thread.sleep(forTimeInterval: 0.001)
        balance = currentBalance + amount
    }

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

// Actors automatically protect their mutable state from concurrent access
actor SafeBankAccount {
    var balance: Double = 0

    func deposit(amount: Double) {
        let currentBalance = balance
        // Simulate some processing time
        try? await Task.sleep(nanoseconds: 1_000_000) // 0.001 seconds
        balance = currentBalance + amount
    }

    func withdraw(amount: Double) {
        let currentBalance = balance
        try? await Task.sleep(nanoseconds: 1_000_000)
        balance = currentBalance - amount
    }

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

actor Counter {
    private var count = 0

    // Methods inside the actor can access mutable state directly (synchronously)
    func increment() {
        count += 1  // No await needed inside the actor
        print("Count incremented to \(count)")
    }

    func decrement() {
        count -= 1
        print("Count decremented to \(count)")
    }

    func getCount() -> Int {
        return count  // Direct access inside the actor
    }

    // You can call other methods of the same actor without await
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

// MainActor is a special actor that runs on the main thread
// Use it for UI updates and main-thread-only operations
@MainActor
class ViewModel {
    var title: String = "Loading..."
    var isLoading: Bool = false

    func updateTitle(_ newTitle: String) {
        // This will always run on the main thread
        title = newTitle
        print("Title updated on main thread: \(title)")
    }

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

actor ImageCache {
    private var cache: [String: Data] = [:]

    func getImage(for key: String) -> Data? {
        return cache[key]
    }

    func setImage(_ data: Data, for key: String) {
        cache[key] = data
        print("Cached image for key: \(key)")
    }

    func removeImage(for key: String) {
        cache[key] = nil
        print("Removed image for key: \(key)")
    }

    func clearCache() {
        cache.removeAll()
        print("Cache cleared")
    }

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

actor DatabaseManager {
    private var connections: [String] = []

    func saveUser(name: String) async {
        print("Saving user: \(name)")
        connections.append(name)

        // This await point allows other tasks to access the actor
        await Task.sleep(1_000_000_000) // 1 second

        // After await, the state might have changed!
        print("User \(name) saved. Total connections: \(connections.count)")
    }

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

actor UserService {
    private var userCount = 0

    // Nonisolated methods don't require await and can't access mutable state
    nonisolated func validateEmail(_ email: String) -> Bool {
        // Cannot access userCount here (it's isolated to the actor)
        return email.contains("@")
    }

    // Regular actor method
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
