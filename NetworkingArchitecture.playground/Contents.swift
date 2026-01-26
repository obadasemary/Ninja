import Foundation
import Combine
import PlaygroundSupport

/*
 # NetworkingArchitecture Playground

 ## Overview
 This playground demonstrates **Clean Architecture** principles applied to networking in Swift.
 It showcases three different asynchronous patterns for handling network requests:

 1. **Completion Handlers** - Traditional callback-based approach
 2. **Combine** - Reactive programming with publishers and subscribers
 3. **Async/Await** - Modern Swift concurrency with structured concurrency

 ## Architecture Layers

 ### 1. Models (Domain Layer)
 - Pure Swift structs representing business entities
 - No dependencies on networking or frameworks
 - Conform to `Codable` for JSON serialization

 ### 2. Network Layer (Data Source)
 - `APIClient` - Handles HTTP communication
 - Abstracts URLSession details
 - Converts raw data into domain models
 - Provides protocol for dependency injection

 ### 3. Repository Layer (Data Access)
 - Abstracts data source implementation details
 - Single source of truth for domain entities
 - Can combine multiple data sources (network, cache, database)
 - Depends on Network Layer protocol, not concrete implementation

 ### 4. Use Case Layer (Business Logic)
 - Contains domain-specific business rules
 - Orchestrates data flow between repositories
 - Applies transformations, filtering, sorting
 - Represents specific user actions or system operations

 ## Benefits of This Architecture

 - **Testability**: Each layer can be tested independently with mocks
 - **Separation of Concerns**: Each layer has a single, well-defined responsibility
 - **Flexibility**: Easy to swap implementations (e.g., mock network for testing)
 - **Scalability**: Clear structure for adding new features
 - **Dependency Inversion**: High-level modules don't depend on low-level modules

 ## Three Async Patterns Comparison

 | Pattern           | Pros                              | Cons                          | Best For                    |
 |-------------------|-----------------------------------|-------------------------------|-----------------------------|
 | Completion Handler| Simple, widely understood         | Callback hell, error prone    | Legacy code, simple requests|
 | Combine           | Powerful operators, composable    | Learning curve, verbose       | Reactive UIs, streams       |
 | Async/Await       | Clean syntax, structured concurrency| Requires iOS 15+             | Modern apps, sequential ops |

 ## Usage Examples
 See the bottom of this file for practical examples demonstrating:
 - Sequential API calls with all three patterns
 - Parallel requests with async/await
 - Error handling strategies
 - Dependency injection in practice
 */

// MARK: - Models

/// Represents a user in the system.
///
/// This is a domain model that represents the core business entity.
/// It's independent of any networking or persistence logic.
///
/// - Note: Conforms to `Codable` for JSON serialization/deserialization
/// - Note: Conforms to `Identifiable` for SwiftUI List support
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let username: String
}

/// Represents a blog post created by a user.
///
/// Each post is associated with a user via the `userId` property.
/// This demonstrates a one-to-many relationship in the domain model.
struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// MARK: - Network Error

/// Comprehensive error types that can occur during network operations.
///
/// This enum provides type-safe error handling with associated values for additional context.
/// By conforming to `LocalizedError`, it provides user-friendly error messages.
///
/// ## Error Cases
///
/// - `invalidURL`: The constructed URL is malformed
/// - `invalidResponse`: Server response is not a valid HTTPURLResponse
/// - `httpError`: Server returned a non-2xx status code
/// - `decodingError`: JSON decoding failed (type mismatch, missing keys, etc.)
/// - `networkError`: Underlying network failure (no connection, timeout, etc.)
///
/// ## Usage Example
/// ```swift
/// do {
///     let users = try await apiClient.requestAsync(endpoint: "/users")
/// } catch let error as NetworkError {
///     print("Network error: \(error.localizedDescription)")
/// }
/// ```
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Async Pattern Conversion Utilities

/// Utilities for converting between different async patterns.
///
/// These extensions provide convenient methods to convert between:
/// - Completion handlers → Combine
/// - Completion handlers → Async/Await
/// - Combine → Async/Await
///
/// ## Use Cases
///
/// - **Legacy Integration**: Convert old completion-based APIs to modern async/await
/// - **Library Bridging**: Wrap third-party completion-based libraries with Combine
/// - **Migration**: Gradually migrate from one pattern to another
/// - **Flexibility**: Provide multiple interfaces for the same functionality
///
/// ## Examples
///
/// ```swift
/// // Convert completion to Combine
/// let publisher: AnyPublisher<[User], NetworkError> = Future { promise in
///     repository.getUsers(completion: promise)
/// }.eraseToAnyPublisher()
///
/// // Convert completion to async/await
/// let users = try await withCheckedThrowingContinuation { continuation in
///     repository.getUsers { result in
///         continuation.resume(with: result)
///     }
/// }
/// ```

/// Extension providing utilities to convert completion-based methods to Combine publishers.
extension AnyPublisher {
    /// Creates a publisher from a completion-based method.
    ///
    /// This utility wraps any completion-based API and converts it to a Combine publisher.
    ///
    /// ## Example
    /// ```swift
    /// // In Repository or Use Case
    /// func getUsersPublisher() -> AnyPublisher<[User], NetworkError> {
    ///     AnyPublisher.fromCompletion { completion in
    ///         self.getUsers(completion: completion)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter work: A closure that performs work and calls the completion handler
    /// - Returns: A publisher that emits the result or error
    static func fromCompletion(
        _ work: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void
    ) -> AnyPublisher<Output, Failure> where Failure: Error {
        Future<Output, Failure> { promise in
            work(promise)
        }
        .eraseToAnyPublisher()
    }
}

/// Extension providing utilities to convert Combine publishers to async/await.
extension AnyPublisher {
    /// Converts a Combine publisher to an async/await result.
    ///
    /// This method bridges the gap between Combine's reactive world and Swift's async/await.
    /// It waits for the first value emitted by the publisher and returns it.
    ///
    /// ## Characteristics
    ///
    /// - Returns the first value emitted by the publisher
    /// - Throws an error if the publisher fails
    /// - Cancels the subscription after receiving the first value
    ///
    /// ## Example
    /// ```swift
    /// // In Use Case
    /// func executeAsync() async throws -> [User] {
    ///     try await executePublisher().toAsync()
    /// }
    /// ```
    ///
    /// ## Note
    /// For streams that emit multiple values, consider using `AsyncStream` or `.values` (iOS 15+)
    ///
    /// - Returns: The first value emitted by the publisher
    /// - Throws: The error if the publisher fails
    func toAsync() async throws -> Output where Failure: Error {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var isResumed = false

            cancellable = self.sink(
                receiveCompletion: { completion in
                    if !isResumed {
                        isResumed = true
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    cancellable?.cancel()
                },
                receiveValue: { value in
                    if !isResumed {
                        isResumed = true
                        continuation.resume(returning: value)
                    }
                    cancellable?.cancel()
                }
            )
        }
    }
}

/// Namespace for completion-to-async utilities.
enum AsyncBridge {
    /// Converts a completion-based method to async/await.
    ///
    /// This utility wraps any completion-based API and converts it to async/await.
    /// It uses Swift's `withCheckedThrowingContinuation` for safe continuation handling.
    ///
    /// ## Example
    /// ```swift
    /// // In Repository or Use Case
    /// func getUsersAsync() async throws -> [User] {
    ///     try await AsyncBridge.fromCompletion { completion in
    ///         self.getUsers(completion: completion)
    ///     }
    /// }
    /// ```
    ///
    /// ## Safety
    ///
    /// - Uses `withCheckedThrowingContinuation` to ensure continuation is resumed exactly once
    /// - Converts `Result<T, E>` to async/await's natural throw mechanism
    /// - Properly propagates errors through the async context
    ///
    /// - Parameter work: A closure that performs work and calls the completion handler
    /// - Returns: The success value from the completion
    /// - Throws: The error from the completion if it failed
    static func fromCompletion<T, E: Error>(
        _ work: @escaping (@escaping (Result<T, E>) -> Void) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            work { result in
                continuation.resume(with: result)
            }
        }
    }
}

// MARK: - Network Layer (API Client)

/// Protocol defining the network service contract.
///
/// This protocol enables **dependency injection** and **testability** by abstracting the network layer.
/// Repositories depend on this protocol rather than the concrete `APIClient` implementation.
///
/// ## Three Async Patterns
///
/// Each method provides the same functionality using different async patterns:
///
/// 1. **Completion Handler** - `request(endpoint:completion:)`
///    - Traditional callback-based approach
///    - Widely compatible (iOS 13+)
///    - Can lead to callback hell with nested requests
///
/// 2. **Combine** - `requestPublisher(endpoint:)`
///    - Reactive programming with operators
///    - Composable with other publishers
///    - Requires iOS 13+, SwiftUI integration
///
/// 3. **Async/Await** - `requestAsync(endpoint:)`
///    - Modern structured concurrency
///    - Clean, linear code flow
///    - Requires iOS 15+
///
/// ## Usage
/// ```swift
/// let apiClient: NetworkServiceProtocol = APIClient()
/// let users: [User] = try await apiClient.requestAsync(endpoint: "/users")
/// ```
protocol NetworkServiceProtocol {
    // Completion Handler
    func request<T: Decodable>(
        endpoint: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )

    // Combine
    func requestPublisher<T: Decodable>(endpoint: String) -> AnyPublisher<T, NetworkError>

    // Async/Await
    func requestAsync<T: Decodable>(endpoint: String) async throws -> T
}

/// Concrete implementation of the network service.
///
/// This class handles all HTTP communication with the JSONPlaceholder API.
/// It demonstrates the **adapter pattern** by wrapping `URLSession` and providing
/// three different async interfaces.
///
/// ## Features
///
/// - Generic `Decodable` support for type-safe responses
/// - Comprehensive error handling with typed errors
/// - Dependency injection of `URLSession` for testing
/// - Three async patterns for different use cases
///
/// ## Testing
///
/// The `URLSession` can be injected for testing:
/// ```swift
/// let mockSession = MockURLSession()
/// let apiClient = APIClient(session: mockSession)
/// ```
class APIClient: NetworkServiceProtocol {
    private let baseURL = "https://jsonplaceholder.typicode.com"
    private let session: URLSession

    /// Creates a new API client with the specified URLSession.
    ///
    /// - Parameter session: The URLSession to use for requests. Defaults to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Completion Handler Implementation

    /// Performs a network request using the completion handler pattern.
    ///
    /// This is the traditional callback-based approach to async networking in Swift.
    /// The completion handler is called on a background thread when the request completes.
    ///
    /// ## Characteristics
    ///
    /// - **Pros**: Simple, widely understood, compatible with all iOS versions
    /// - **Cons**: Can lead to callback hell, requires manual thread management
    /// - **Best for**: Legacy codebases, simple one-off requests
    ///
    /// ## Example
    /// ```swift
    /// apiClient.request(endpoint: "/users") { (result: Result<[User], NetworkError>) in
    ///     DispatchQueue.main.async {
    ///         switch result {
    ///         case .success(let users):
    ///             print("Got \(users.count) users")
    ///         case .failure(let error):
    ///             print("Error: \(error)")
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint path (e.g., "/users" or "/posts/1")
    ///   - completion: Callback invoked with the result. Called on a background thread.
    func request<T: Decodable>(
        endpoint: String,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(statusCode: httpResponse.statusCode)))
                return
            }

            // Validate and decode data
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }

        task.resume()
    }

    // MARK: - Combine Implementation

    /// Performs a network request using the Combine framework.
    ///
    /// Returns a publisher that emits the decoded response or an error.
    /// This enables reactive programming patterns and powerful operator composition.
    ///
    /// ## Characteristics
    ///
    /// - **Pros**: Composable with operators, automatic memory management, declarative
    /// - **Cons**: Learning curve, can be verbose for simple cases
    /// - **Best for**: Reactive UIs (SwiftUI), chaining multiple requests, data streams
    ///
    /// ## Example
    /// ```swift
    /// var cancellables = Set<AnyCancellable>()
    ///
    /// apiClient.requestPublisher(endpoint: "/users")
    ///     .map { users in users.filter { $0.email.contains("@") } }
    ///     .sink(
    ///         receiveCompletion: { completion in
    ///             if case .failure(let error) = completion {
    ///                 print("Error: \(error)")
    ///             }
    ///         },
    ///         receiveValue: { users in
    ///             print("Got \(users.count) users")
    ///         }
    ///     )
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// - Parameter endpoint: The API endpoint path (e.g., "/users" or "/posts/1")
    /// - Returns: A publisher that emits the decoded response or a `NetworkError`
    func requestPublisher<T: Decodable>(endpoint: String) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(statusCode: httpResponse.statusCode)
                }

                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                }

                if error is DecodingError {
                    return .decodingError(error)
                }

                return .networkError(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Async/Await Implementation

    /// Performs a network request using Swift's async/await pattern.
    ///
    /// This is the modern approach to asynchronous programming in Swift.
    /// It provides structured concurrency with clean, linear code flow.
    ///
    /// ## Characteristics
    ///
    /// - **Pros**: Clean syntax, structured concurrency, automatic Task cancellation
    /// - **Cons**: Requires iOS 15+, must be called from async context
    /// - **Best for**: Modern apps, sequential operations, parallel requests with `async let`
    ///
    /// ## Example
    /// ```swift
    /// Task {
    ///     do {
    ///         let users: [User] = try await apiClient.requestAsync(endpoint: "/users")
    ///         print("Got \(users.count) users")
    ///
    ///         // Sequential request
    ///         let posts: [Post] = try await apiClient.requestAsync(endpoint: "/posts")
    ///         print("Got \(posts.count) posts")
    ///     } catch {
    ///         print("Error: \(error)")
    ///     }
    /// }
    /// ```
    ///
    /// ## Parallel Requests
    /// ```swift
    /// async let users: [User] = apiClient.requestAsync(endpoint: "/users")
    /// async let posts: [Post] = apiClient.requestAsync(endpoint: "/posts")
    /// let (usersResult, postsResult) = try await (users, posts)
    /// ```
    ///
    /// - Parameter endpoint: The API endpoint path (e.g., "/users" or "/posts/1")
    /// - Returns: The decoded response of type `T`
    /// - Throws: `NetworkError` if the request fails
    func requestAsync<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}

// MARK: - Repository Layer

/// Repository pattern for User entities.
///
/// The **Repository Pattern** provides an abstraction over data access logic.
/// It acts as a collection-like interface for accessing domain objects.
///
/// ## Purpose
///
/// - Decouples business logic from data source implementation
/// - Provides a single source of truth for User data
/// - Can aggregate data from multiple sources (API, cache, database)
/// - Simplifies testing by allowing mock implementations
///
/// ## Clean Architecture Benefits
///
/// In Clean Architecture, repositories belong to the **Interface Adapters** layer.
/// They convert data from the format most convenient for use cases (domain models)
/// to the format most convenient for external services (DTOs, network models).
///
/// - Use Cases depend on Repository **protocols** (dependency inversion)
/// - Repository implementations depend on Network Layer protocols
/// - Changes to the network layer don't affect use cases
///
/// ## Example
/// ```swift
/// // In production
/// let apiClient: NetworkServiceProtocol = APIClient()
/// let userRepository: UserRepositoryProtocol = UserRepository(networkService: apiClient)
///
/// // In tests
/// let mockNetwork = MockNetworkService()
/// let userRepository: UserRepositoryProtocol = UserRepository(networkService: mockNetwork)
/// ```
protocol UserRepositoryProtocol {
    // Completion Handler
    func getUsers(completion: @escaping (Result<[User], NetworkError>) -> Void)
    func getUser(id: Int, completion: @escaping (Result<User, NetworkError>) -> Void)

    // Combine
    func getUsersPublisher() -> AnyPublisher<[User], NetworkError>
    func getUserPublisher(id: Int) -> AnyPublisher<User, NetworkError>

    // Async/Await
    func getUsersAsync() async throws -> [User]
    func getUserAsync(id: Int) async throws -> User
}

/// Repository pattern for Post entities.
///
/// Provides access to post data with the same three async patterns.
/// Demonstrates how repositories can provide domain-specific query methods
/// (like `getUserPosts`) beyond simple CRUD operations.
protocol PostRepositoryProtocol {
    // Completion Handler
    func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void)
    func getUserPosts(userId: Int, completion: @escaping (Result<[Post], NetworkError>) -> Void)

    // Combine
    func getPostsPublisher() -> AnyPublisher<[Post], NetworkError>
    func getUserPostsPublisher(userId: Int) -> AnyPublisher<[Post], NetworkError>

    // Async/Await
    func getPostsAsync() async throws -> [Post]
    func getUserPostsAsync(userId: Int) async throws -> [Post]
}

// MARK: - Repository Implementations

/// Concrete implementation of User repository using the network service.
///
/// This class is a **thin wrapper** around the network service.
/// In a real application, it might also:
///
/// - Cache responses in memory or disk
/// - Merge data from multiple sources (network + local database)
/// - Handle offline scenarios
/// - Implement retry logic
/// - Track loading states
///
/// ## Dependency Injection
///
/// The repository depends on `NetworkServiceProtocol`, not `APIClient`.
/// This enables:
/// - Testing with mock network services
/// - Swapping implementations without changing the repository
/// - Following the **Dependency Inversion Principle**
class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    /// Creates a new user repository.
    ///
    /// - Parameter networkService: The network service to use for fetching users.
    ///                             Can be a real `APIClient` or a mock for testing.
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - Completion Handler

    func getUsers(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        networkService.request(endpoint: "/users", completion: completion)
    }

    func getUser(id: Int, completion: @escaping (Result<User, NetworkError>) -> Void) {
        networkService.request(endpoint: "/users/\(id)", completion: completion)
    }

    // MARK: - Combine

    func getUsersPublisher() -> AnyPublisher<[User], NetworkError> {
        networkService.requestPublisher(endpoint: "/users")
    }

    func getUserPublisher(id: Int) -> AnyPublisher<User, NetworkError> {
        networkService.requestPublisher(endpoint: "/users/\(id)")
    }

    // MARK: - Async/Await

    func getUsersAsync() async throws -> [User] {
        try await networkService.requestAsync(endpoint: "/users")
    }

    func getUserAsync(id: Int) async throws -> User {
        try await networkService.requestAsync(endpoint: "/users/\(id)")
    }
}

class PostRepository: PostRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // MARK: - Completion Handler

    func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        networkService.request(endpoint: "/posts", completion: completion)
    }

    func getUserPosts(userId: Int, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        networkService.request(endpoint: "/posts?userId=\(userId)", completion: completion)
    }

    // MARK: - Combine

    func getPostsPublisher() -> AnyPublisher<[Post], NetworkError> {
        networkService.requestPublisher(endpoint: "/posts")
    }

    func getUserPostsPublisher(userId: Int) -> AnyPublisher<[Post], NetworkError> {
        networkService.requestPublisher(endpoint: "/posts?userId=\(userId)")
    }

    // MARK: - Async/Await

    func getPostsAsync() async throws -> [Post] {
        try await networkService.requestAsync(endpoint: "/posts")
    }

    func getUserPostsAsync(userId: Int) async throws -> [Post] {
        try await networkService.requestAsync(endpoint: "/posts?userId=\(userId)")
    }
}

// MARK: - Use Case Layer

/// Protocol for the "Get Users" use case.
///
/// ## What is a Use Case?
///
/// A **Use Case** (also called an Interactor) represents a single business operation
/// or user action in your application. It contains the **business logic** specific to
/// that operation.
///
/// ## Responsibilities
///
/// - Orchestrate data flow between repositories
/// - Apply business rules and transformations
/// - Coordinate multiple repositories if needed
/// - Contain domain-specific logic (filtering, sorting, validation)
/// - **NOT** responsible for presentation or data fetching
///
/// ## Why Use Cases?
///
/// - **Single Responsibility**: Each use case does one thing
/// - **Testability**: Business logic is isolated and easy to test
/// - **Reusability**: Use cases can be shared across ViewModels/ViewControllers
/// - **Clarity**: Clear intent - the name describes what it does
///
/// ## Example Use Cases in a Real App
///
/// - `LoginUserUseCase` - Validates credentials and creates a session
/// - `SearchProductsUseCase` - Searches products with filters and sorting
/// - `CheckoutCartUseCase` - Validates cart, applies discounts, creates order
///
/// ## Clean Architecture Placement
///
/// Use Cases are in the **Application Business Rules** layer (innermost layer).
/// They depend on repository protocols, not implementations.
protocol GetUsersUseCaseProtocol {
    // Completion Handler
    func execute(completion: @escaping (Result<[User], NetworkError>) -> Void)

    // Combine
    func executePublisher() -> AnyPublisher<[User], NetworkError>

    // Async/Await
    func executeAsync() async throws -> [User]
}

protocol GetUserPostsUseCaseprotocol {
    // Completion Handler
    func execute(userId: Int, completion: @escaping (Result<[Post], NetworkError>) -> Void)

    // Combine
    func executePublisher(userId: Int) -> AnyPublisher<[Post], NetworkError>

    // Async/Await
    func executeAsync(userId: Int) async throws -> [Post]
}

// MARK: - Use Case Implementations

/// Implementation of the "Get Users" use case.
///
/// This use case demonstrates how business logic is applied in the use case layer.
/// It fetches users from the repository and filters out users with empty emails.
///
/// ## Business Logic Example
///
/// In this example, the business rule is: "Only return users with valid email addresses."
/// This logic lives in the use case, not in the repository or network layer.
///
/// ## Real-World Examples
///
/// In a production app, use cases might:
/// - Combine data from multiple repositories
/// - Apply complex business rules and calculations
/// - Validate business constraints
/// - Transform data for specific presentation needs
/// - Log analytics events
/// - Handle caching strategies
///
/// ## Testability
///
/// Use cases are highly testable because they:
/// - Depend on repository protocols (can inject mocks)
/// - Contain pure business logic
/// - Have clear inputs and outputs
class GetUsersUseCase: GetUsersUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol

    /// Creates a new use case instance.
    ///
    /// - Parameter userRepository: Repository for accessing user data.
    ///                             Can be a real repository or mock for testing.
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

    /// Executes the use case using completion handlers.
    ///
    /// Fetches all users and applies the business rule: filter out users with empty emails.
    ///
    /// - Parameter completion: Called with filtered users or error
    func execute(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        userRepository.getUsers { result in
            switch result {
            case .success(let users):
                // Apply business logic here (filtering, sorting, transformation, etc.)
                let filteredUsers = users.filter { !$0.email.isEmpty }
                completion(.success(filteredUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func executePublisher() -> AnyPublisher<[User], NetworkError> {
        userRepository.getUsersPublisher()
            .map { users in
                // Apply business logic
                users.filter { !$0.email.isEmpty }
            }
            .eraseToAnyPublisher()
    }

    func executeAsync() async throws -> [User] {
        let users = try await userRepository.getUsersAsync()
        // Apply business logic
        return users.filter { !$0.email.isEmpty }
    }
}

class GetUserPostsUseCase: GetUserPostsUseCaseprotocol {
    private let postRepository: PostRepositoryProtocol

    init(postRepository: PostRepositoryProtocol) {
        self.postRepository = postRepository
    }

    func execute(userId: Int, completion: @escaping (Result<[Post], NetworkError>) -> Void) {
        postRepository.getUserPosts(userId: userId) { result in
            switch result {
            case .success(let posts):
                // Apply business logic (e.g., sort by title)
                let sortedPosts = posts.sorted { $0.title < $1.title }
                completion(.success(sortedPosts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func executePublisher(userId: Int) -> AnyPublisher<[Post], NetworkError> {
        postRepository.getUserPostsPublisher(userId: userId)
            .map { posts in
                // Apply business logic
                posts.sorted { $0.title < $1.title }
            }
            .eraseToAnyPublisher()
    }

    func executeAsync(userId: Int) async throws -> [Post] {
        let posts = try await postRepository.getUserPostsAsync(userId: userId)
        // Apply business logic
        return posts.sorted { $0.title < $1.title }
    }
}

// MARK: - Conversion Utilities Demo

/*
 ## Async Pattern Conversion Examples

 This section demonstrates how to use the conversion utilities to transform
 between completion handlers, Combine, and async/await patterns.

 ### Conversion Scenarios

 1. **Completion → Combine**: Wrap legacy APIs in reactive publishers
 2. **Completion → Async/Await**: Modernize callback-based code
 3. **Combine → Async/Await**: Bridge reactive code with structured concurrency
 */

/// Example: Repository using conversion utilities
class ConvertibleUserRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    // Original completion-based method
    func getUsers(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        networkService.request(endpoint: "/users", completion: completion)
    }

    // MARK: - Completion → Combine Conversion

    /// Converts the completion-based getUsers to a Combine publisher.
    ///
    /// This demonstrates how to wrap a completion-based method in a publisher
    /// using the `AnyPublisher.fromCompletion` utility.
    ///
    /// ## Example Usage
    /// ```swift
    /// repository.getUsersPublisherFromCompletion()
    ///     .sink(
    ///         receiveCompletion: { _ in },
    ///         receiveValue: { users in print(users) }
    ///     )
    ///     .store(in: &cancellables)
    /// ```
    func getUsersPublisherFromCompletion() -> AnyPublisher<[User], NetworkError> {
        AnyPublisher.fromCompletion { completion in
            self.getUsers(completion: completion)
        }
    }

    // MARK: - Completion → Async/Await Conversion

    /// Converts the completion-based getUsers to async/await.
    ///
    /// This demonstrates how to wrap a completion-based method in async/await
    /// using the `AsyncBridge.fromCompletion` utility.
    ///
    /// ## Example Usage
    /// ```swift
    /// Task {
    ///     let users = try await repository.getUsersAsyncFromCompletion()
    ///     print(users)
    /// }
    /// ```
    func getUsersAsyncFromCompletion() async throws -> [User] {
        try await AsyncBridge.fromCompletion { completion in
            self.getUsers(completion: completion)
        }
    }
}

/// Example: Use Case using conversion utilities
class ConvertibleGetUsersUseCase {
    private let userRepository: ConvertibleUserRepository

    init(userRepository: ConvertibleUserRepository) {
        self.userRepository = userRepository
    }

    // Original completion-based method with business logic
    func execute(completion: @escaping (Result<[User], NetworkError>) -> Void) {
        userRepository.getUsers { result in
            switch result {
            case .success(let users):
                let filteredUsers = users.filter { !$0.email.isEmpty }
                completion(.success(filteredUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Completion → Combine Conversion

    /// Converts the completion-based execute to a Combine publisher.
    ///
    /// This shows how to apply business logic while converting to Combine.
    func executePublisherFromCompletion() -> AnyPublisher<[User], NetworkError> {
        AnyPublisher.fromCompletion { completion in
            self.execute(completion: completion)
        }
    }

    // MARK: - Completion → Async/Await Conversion

    /// Converts the completion-based execute to async/await.
    ///
    /// This shows how to apply business logic while converting to async/await.
    func executeAsyncFromCompletion() async throws -> [User] {
        try await AsyncBridge.fromCompletion { completion in
            self.execute(completion: completion)
        }
    }

    // MARK: - Combine → Async/Await Conversion

    /// Demonstrates converting a Combine publisher to async/await.
    ///
    /// This is useful when you have a Combine-based API but need to call it
    /// from an async context.
    func executeAsyncFromPublisher() async throws -> [User] {
        try await userRepository.getUsersPublisherFromCompletion()
            .map { users in
                // Apply business logic in the Combine chain
                users.filter { !$0.email.isEmpty }
            }
            .toAsync()
    }
}

// MARK: - Conversion Demo Usage

print("\n" + String(repeating: "=", count: 50))
print("🔄 ASYNC PATTERN CONVERSION DEMO")
print(String(repeating: "=", count: 50) + "\n")

let convertibleRepo = ConvertibleUserRepository(networkService: apiClient)
let convertibleUseCase = ConvertibleGetUsersUseCase(userRepository: convertibleRepo)

// Example 1: Completion → Combine
print("1️⃣ Converting Completion to Combine\n")
convertibleRepo.getUsersPublisherFromCompletion()
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("❌ Error: \(error)")
            }
        },
        receiveValue: { users in
            print("✅ Converted completion to Combine: \(users.count) users")
        }
    )
    .store(in: &cancellables)

// Example 2: Completion → Async/Await
print("\n2️⃣ Converting Completion to Async/Await\n")
Task {
    do {
        let users = try await convertibleRepo.getUsersAsyncFromCompletion()
        print("✅ Converted completion to async/await: \(users.count) users")
    } catch {
        print("❌ Error: \(error)")
    }
}

// Example 3: Combine → Async/Await
print("\n3️⃣ Converting Combine to Async/Await\n")
Task {
    do {
        let users = try await convertibleUseCase.executeAsyncFromPublisher()
        print("✅ Converted Combine to async/await: \(users.count) users")
        print("   (with business logic applied)")
    } catch {
        print("❌ Error: \(error)")
    }
}

print("\n" + String(repeating: "=", count: 50) + "\n")

/*
 ## Conversion Utilities - When to Use

 ### 1. Completion → Combine (AnyPublisher.fromCompletion)

 **Use When:**
 - You have a legacy completion-based API
 - You want to use Combine operators (map, flatMap, combineLatest, etc.)
 - You need to compose multiple async operations reactively
 - You're building a SwiftUI app with @Published properties

 **Benefits:**
 - Access to powerful Combine operators
 - Easy chaining and composition
 - Automatic memory management with AnyCancellable
 - Natural fit for reactive UIs

 **Example Use Case:**
 ```swift
 // Combine multiple APIs reactively
 let publisher = repository.getUsersPublisherFromCompletion()
     .flatMap { users -> AnyPublisher<[Post], NetworkError> in
         repository.getPostsPublisherFromCompletion()
     }
     .map { posts in posts.filter { $0.title.contains("Swift") } }
 ```

 ### 2. Completion → Async/Await (AsyncBridge.fromCompletion)

 **Use When:**
 - You're modernizing a legacy codebase
 - You want clean, linear async code
 - You're targeting iOS 15+
 - You need to use Task groups or structured concurrency

 **Benefits:**
 - Clean, readable code without nested callbacks
 - Native error handling with try/catch
 - Works seamlessly with @MainActor
 - Easy to reason about sequential operations

 **Example Use Case:**
 ```swift
 // Clean sequential operations
 func loadUserData() async throws {
     let users = try await repository.getUsersAsyncFromCompletion()
     let firstUser = users.first!
     let posts = try await repository.getUserPostsAsyncFromCompletion(userId: firstUser.id)
     // No callback hell!
 }
 ```

 ### 3. Combine → Async/Await (AnyPublisher.toAsync)

 **Use When:**
 - You have a Combine-based library but need async/await interface
 - You're gradually migrating from Combine to async/await
 - You want to use Combine operators then await the final result
 - You need to call Combine APIs from async functions

 **Benefits:**
 - Bridge between reactive and structured concurrency
 - Use Combine's powerful operators, then await the result
 - Simplifies migration path
 - Best of both worlds

 **Example Use Case:**
 ```swift
 // Use Combine operators, then await
 func getFilteredUsers() async throws -> [User] {
     try await repository.getUsersPublisher()
         .map { $0.filter { $0.email.contains("@") } }
         .map { $0.sorted { $0.name < $1.name } }
         .toAsync()
 }
 ```

 ### Conversion Pattern Matrix

 | From             | To               | Use                              | Method                           |
 |------------------|------------------|----------------------------------|----------------------------------|
 | Completion       | Combine          | Reactive composition             | `AnyPublisher.fromCompletion`   |
 | Completion       | Async/Await      | Modern sequential code           | `AsyncBridge.fromCompletion`    |
 | Combine          | Async/Await      | Await reactive streams           | `publisher.toAsync()`           |

 ### Migration Strategy

 **Gradual Migration Approach:**

 1. **Phase 1**: Add conversion methods alongside existing APIs
    ```swift
    // Keep existing
    func getUsers(completion: ...)
    // Add new
    func getUsersAsync() async throws -> [User] {
        try await AsyncBridge.fromCompletion { self.getUsers(completion: $0) }
    }
    ```

 2. **Phase 2**: Migrate callers to new APIs gradually
 3. **Phase 3**: Deprecate old APIs
 4. **Phase 4**: Remove deprecated APIs after migration

 **Full Rewrite Approach:**

 1. Choose target pattern (usually async/await for new code)
 2. Rewrite all methods in new pattern
 3. Use conversion utilities only at boundaries (e.g., third-party SDKs)

 ### Best Practices

 ✅ **Do:**
 - Use conversions at architecture boundaries
 - Document which pattern is "canonical" for your codebase
 - Be consistent within each module
 - Use conversion utilities for third-party libraries

 ❌ **Don't:**
 - Convert back and forth repeatedly in the same call chain
 - Mix patterns unnecessarily in new code
 - Use conversions as a substitute for proper refactoring
 - Forget to handle cancellation properly

 ### Performance Considerations

 - **Completion handlers**: Lowest overhead, most direct
 - **Combine**: Some overhead from publisher machinery, but negligible for most apps
 - **Async/Await**: Optimized by compiler, similar to completion handlers
 - **Conversions**: Small overhead from bridging, acceptable for most use cases

 The performance difference is typically insignificant compared to network I/O.
 Choose based on code clarity and maintainability, not micro-optimization.
 */

// MARK: - Unit Tests

/*
 ## Unit Testing Architecture

 This playground demonstrates comprehensive unit testing of the Clean Architecture layers.

 ### Testing Strategy

 #### 1. Test Pyramid
 - **Unit Tests**: Test each layer in isolation (what we're doing here)
 - **Integration Tests**: Test layers working together
 - **UI Tests**: Test the full app flow

 #### 2. Dependency Injection Benefits
 Because each layer depends on protocols, we can inject mocks for testing:

 ```
 Production:                    Testing:
 UseCase → Repository → API     UseCase → MockRepository
 Repository → Network           Repository → MockNetwork
 ```

 #### 3. What We're Testing

 - **Repository Tests**: Verify repositories correctly delegate to network service
 - **Use Case Tests**: Verify business logic is applied correctly
 - **Error Handling**: Ensure errors propagate correctly
 - **All Three Patterns**: Test completion handlers, Combine, and async/await

 ### Mock Strategy

 The `MockNetworkService` is a **test double** that:
 - Implements `NetworkServiceProtocol`
 - Returns configurable mock data
 - Can simulate errors
 - Doesn't make real network calls
 - Enables fast, deterministic tests

 This is the **Dependency Inversion Principle** in action:
 - Production code depends on abstractions (protocols)
 - Test code provides alternative implementations
 - No changes needed to production code for testing
 */

import XCTest

// MARK: - Mock Network Service

/// Mock implementation of the network service for testing.
///
/// This test double allows us to test repositories and use cases
/// without making real network calls.
///
/// ## Configuration
///
/// ```swift
/// let mock = MockNetworkService()
/// mock.shouldReturnError = false  // Simulate success
/// mock.mockUsers = [testUser1, testUser2]
/// mock.shouldReturnError = true   // Simulate failure
/// mock.mockError = .httpError(statusCode: 500)
/// ```
class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var mockError: NetworkError = .invalidResponse
    var mockUsers: [User] = []
    var mockPosts: [Post] = []

    // Completion Handler
    func request<T: Decodable>(endpoint: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        if shouldReturnError {
            completion(.failure(mockError))
            return
        }

        if T.self == [User].self {
            completion(.success(mockUsers as! T))
        } else if T.self == User.self {
            completion(.success(mockUsers.first as! T))
        } else if T.self == [Post].self {
            completion(.success(mockPosts as! T))
        }
    }

    // Combine
    func requestPublisher<T: Decodable>(endpoint: String) -> AnyPublisher<T, NetworkError> {
        if shouldReturnError {
            return Fail(error: mockError).eraseToAnyPublisher()
        }

        if T.self == [User].self {
            return Just(mockUsers as! T)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else if T.self == User.self {
            return Just(mockUsers.first as! T)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else if T.self == [Post].self {
            return Just(mockPosts as! T)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
    }

    // Async/Await
    func requestAsync<T: Decodable>(endpoint: String) async throws -> T {
        if shouldReturnError {
            throw mockError
        }

        if T.self == [User].self {
            return mockUsers as! T
        } else if T.self == User.self {
            return mockUsers.first as! T
        } else if T.self == [Post].self {
            return mockPosts as! T
        }

        throw NetworkError.invalidResponse
    }
}

// MARK: - Test Cases

class UserRepositoryTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var repository: UserRepository!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        repository = UserRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        repository = nil
        super.tearDown()
    }

    // MARK: - Completion Handler Tests

    func testGetUsersSuccess() {
        let expectation = XCTestExpectation(description: "Get users successfully")

        let mockUser = User(id: 1, name: "John Doe", email: "john@example.com", username: "johndoe")
        mockNetworkService.mockUsers = [mockUser]

        repository.getUsers { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 1)
                XCTAssertEqual(users.first?.name, "John Doe")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetUsersFailure() {
        let expectation = XCTestExpectation(description: "Get users failure")

        mockNetworkService.shouldReturnError = true
        mockNetworkService.mockError = .httpError(statusCode: 500)

        repository.getUsers { result in
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                if case .httpError(let statusCode) = error {
                    XCTAssertEqual(statusCode, 500)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Async/Await Tests

    func testGetUsersAsync() async throws {
        let mockUser = User(id: 1, name: "Jane Doe", email: "jane@example.com", username: "janedoe")
        mockNetworkService.mockUsers = [mockUser]

        let users = try await repository.getUsersAsync()

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users.first?.name, "Jane Doe")
        XCTAssertEqual(users.first?.email, "jane@example.com")
    }

    func testGetUserAsync() async throws {
        let mockUser = User(id: 1, name: "Test User", email: "test@example.com", username: "testuser")
        mockNetworkService.mockUsers = [mockUser]

        let user = try await repository.getUserAsync(id: 1)

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
    }

    func testGetUsersAsyncError() async {
        mockNetworkService.shouldReturnError = true
        mockNetworkService.mockError = .networkError(NSError(domain: "test", code: -1))

        do {
            _ = try await repository.getUsersAsync()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    // MARK: - Combine Tests

    func testGetUsersPublisher() {
        let expectation = XCTestExpectation(description: "Get users via Combine")
        var cancellables = Set<AnyCancellable>()

        let mockUser = User(id: 1, name: "Combine User", email: "combine@example.com", username: "combineuser")
        mockNetworkService.mockUsers = [mockUser]

        repository.getUsersPublisher()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success but got failure")
                    }
                },
                receiveValue: { users in
                    XCTAssertEqual(users.count, 1)
                    XCTAssertEqual(users.first?.name, "Combine User")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

class PostRepositoryTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var repository: PostRepository!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        repository = PostRepository(networkService: mockNetworkService)
    }

    override func tearDown() {
        mockNetworkService = nil
        repository = nil
        super.tearDown()
    }

    func testGetPostsAsync() async throws {
        let mockPost = Post(userId: 1, id: 1, title: "Test Post", body: "Test Body")
        mockNetworkService.mockPosts = [mockPost]

        let posts = try await repository.getPostsAsync()

        XCTAssertEqual(posts.count, 1)
        XCTAssertEqual(posts.first?.title, "Test Post")
        XCTAssertEqual(posts.first?.userId, 1)
    }

    func testGetUserPostsAsync() async throws {
        let mockPost1 = Post(userId: 1, id: 1, title: "Post 1", body: "Body 1")
        let mockPost2 = Post(userId: 1, id: 2, title: "Post 2", body: "Body 2")
        mockNetworkService.mockPosts = [mockPost1, mockPost2]

        let posts = try await repository.getUserPostsAsync(userId: 1)

        XCTAssertEqual(posts.count, 2)
        XCTAssertEqual(posts.first?.userId, 1)
    }
}

class GetUsersUseCaseTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var userRepository: UserRepository!
    var useCase: GetUsersUseCase!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        userRepository = UserRepository(networkService: mockNetworkService)
        useCase = GetUsersUseCase(userRepository: userRepository)
    }

    override func tearDown() {
        mockNetworkService = nil
        userRepository = nil
        useCase = nil
        super.tearDown()
    }

    func testExecuteFiltersEmptyEmails() {
        let expectation = XCTestExpectation(description: "Use case filters users")

        let user1 = User(id: 1, name: "Valid User", email: "valid@example.com", username: "valid")
        let user2 = User(id: 2, name: "Invalid User", email: "", username: "invalid")
        mockNetworkService.mockUsers = [user1, user2]

        useCase.execute { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 1, "Should filter out users with empty emails")
                XCTAssertEqual(users.first?.name, "Valid User")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testExecuteAsync() async throws {
        let user1 = User(id: 1, name: "User 1", email: "user1@example.com", username: "user1")
        let user2 = User(id: 2, name: "User 2", email: "user2@example.com", username: "user2")
        mockNetworkService.mockUsers = [user1, user2]

        let users = try await useCase.executeAsync()

        XCTAssertEqual(users.count, 2)
        XCTAssertTrue(users.allSatisfy { !$0.email.isEmpty })
    }

    func testExecutePublisher() {
        let expectation = XCTestExpectation(description: "Use case Combine test")
        var cancellables = Set<AnyCancellable>()

        let user = User(id: 1, name: "Test", email: "test@example.com", username: "test")
        mockNetworkService.mockUsers = [user]

        useCase.executePublisher()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { users in
                    XCTAssertEqual(users.count, 1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }
}

class GetUserPostsUseCaseTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var postRepository: PostRepository!
    var useCase: GetUserPostsUseCase!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        postRepository = PostRepository(networkService: mockNetworkService)
        useCase = GetUserPostsUseCase(postRepository: postRepository)
    }

    override func tearDown() {
        mockNetworkService = nil
        postRepository = nil
        useCase = nil
        super.tearDown()
    }

    func testExecuteSortsPosts() {
        let expectation = XCTestExpectation(description: "Use case sorts posts")

        let post1 = Post(userId: 1, id: 1, title: "Zebra", body: "Body 1")
        let post2 = Post(userId: 1, id: 2, title: "Apple", body: "Body 2")
        let post3 = Post(userId: 1, id: 3, title: "Mango", body: "Body 3")
        mockNetworkService.mockPosts = [post1, post2, post3]

        useCase.execute(userId: 1) { result in
            switch result {
            case .success(let posts):
                XCTAssertEqual(posts.count, 3)
                XCTAssertEqual(posts[0].title, "Apple", "Posts should be sorted alphabetically")
                XCTAssertEqual(posts[1].title, "Mango")
                XCTAssertEqual(posts[2].title, "Zebra")
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testExecuteAsync() async throws {
        let post1 = Post(userId: 1, id: 1, title: "C Post", body: "Body")
        let post2 = Post(userId: 1, id: 2, title: "A Post", body: "Body")
        let post3 = Post(userId: 1, id: 3, title: "B Post", body: "Body")
        mockNetworkService.mockPosts = [post1, post2, post3]

        let posts = try await useCase.executeAsync(userId: 1)

        XCTAssertEqual(posts.count, 3)
        XCTAssertEqual(posts[0].title, "A Post")
        XCTAssertEqual(posts[1].title, "B Post")
        XCTAssertEqual(posts[2].title, "C Post")
    }
}

// MARK: - Test Runner

class TestObserver: NSObject, XCTestObservation {
    var testsPassed = 0
    var testsFailed = 0
    var currentSuite = ""
    var suiteResults: [String: (passed: Int, failed: Int)] = [:]

    func testBundleWillStart(_ testBundle: Bundle) {
        print("\n" + String(repeating: "=", count: 50))
        print("🧪 RUNNING UNIT TESTS")
        print(String(repeating: "=", count: 50) + "\n")
    }

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        if testSuite.name.contains("Tests") {
            currentSuite = testSuite.name
            suiteResults[currentSuite] = (passed: 0, failed: 0)
        }
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        if testCase.testRun?.hasSucceeded ?? false {
            testsPassed += 1
            if let current = suiteResults[currentSuite] {
                suiteResults[currentSuite] = (current.passed + 1, current.failed)
            }
        } else {
            testsFailed += 1
            if let current = suiteResults[currentSuite] {
                suiteResults[currentSuite] = (current.passed, current.failed + 1)
            }
        }
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        // Print suite results
        for (suiteName, results) in suiteResults.sorted(by: { $0.key < $1.key }) {
            let total = results.passed + results.failed
            let status = results.failed == 0 ? "✅" : "❌"
            print("\(status) \(suiteName): \(results.passed)/\(total) passed")
        }

        let total = testsPassed + testsFailed
        print("\n" + String(repeating: "-", count: 50))
        print("📊 Test Summary:")
        print("   Total: \(total)")
        print("   ✅ Passed: \(testsPassed)")
        print("   ❌ Failed: \(testsFailed)")
        print(String(repeating: "=", count: 50) + "\n")
    }
}

// Run unit tests first
let observer = TestObserver()
XCTestObservationCenter.shared.addTestObserver(observer)

// Run all test suites
let testSuites: [XCTestCase.Type] = [
    UserRepositoryTests.self,
    PostRepositoryTests.self,
    GetUsersUseCaseTests.self,
    GetUserPostsUseCaseTests.self
]

for testSuiteType in testSuites {
    let suite = XCTestSuite(forTestCaseClass: testSuiteType)
    suite.run()
}

// MARK: - Usage Examples

/*
 ## Practical Usage Examples

 The following examples demonstrate the architecture in action with real API calls
 to JSONPlaceholder (a free fake API for testing).

 ### What You'll See

 1. **Completion Handler Pattern** - Traditional callback-based networking
 2. **Combine Pattern** - Reactive programming with publishers
 3. **Async/Await Pattern** - Modern structured concurrency
 4. **Parallel Requests** - Fetching multiple resources simultaneously with async/await
 5. **Error Handling** - Gracefully handling network failures

 ### Choosing the Right Pattern

 | Scenario                          | Recommended Pattern   | Why?                                      |
 |-----------------------------------|-----------------------|-------------------------------------------|
 | SwiftUI app (iOS 15+)             | Async/Await           | Clean syntax, works well with @MainActor  |
 | SwiftUI app (iOS 13-14)           | Combine               | Native integration with @Published        |
 | UIKit app with reactive updates   | Combine               | Easy to bind to UI updates                |
 | Legacy codebase                   | Completion Handlers   | Compatibility, familiar to all developers |
 | Multiple parallel requests        | Async/Await           | `async let` makes parallelism trivial     |
 | Chaining many transformations     | Combine               | Rich operator library                     |

 ### Dependency Injection in Practice

 Notice how dependencies are created and injected:

 ```swift
 // 1. Create the concrete network service
 let apiClient = APIClient()

 // 2. Inject it into repositories (depend on protocol)
 let userRepository = UserRepository(networkService: apiClient)

 // 3. Inject repositories into use cases (depend on protocol)
 let getUsersUseCase = GetUsersUseCase(userRepository: userRepository)
 ```

 This creates a **dependency graph** that flows one direction:
 UseCase → Repository → NetworkService → URLSession

 Each layer knows only about the layer immediately below it through protocols.
 */

print("=== Networking Architecture Playground ===\n")

// Setup dependencies
let apiClient = APIClient()
let userRepository = UserRepository(networkService: apiClient)
let postRepository = PostRepository(networkService: apiClient)
let getUsersUseCase = GetUsersUseCase(userRepository: userRepository)
let getUserPostsUseCase = GetUserPostsUseCase(postRepository: postRepository)

// MARK: - Example 1: Completion Handler Pattern

print("1️⃣ COMPLETION HANDLER PATTERN\n")

getUsersUseCase.execute { result in
    switch result {
    case .success(let users):
        print("✅ Fetched \(users.count) users (Completion Handler)")
        if let firstUser = users.first {
            print("   First user: \(firstUser.name) (\(firstUser.email))")

            // Fetch posts for the first user
            getUserPostsUseCase.execute(userId: firstUser.id) { postsResult in
                switch postsResult {
                case .success(let posts):
                    print("✅ Fetched \(posts.count) posts for user \(firstUser.name)")
                    if let firstPost = posts.first {
                        print("   First post: \(firstPost.title)")
                    }
                case .failure(let error):
                    print("❌ Error fetching posts: \(error.localizedDescription)")
                }
            }
        }
    case .failure(let error):
        print("❌ Error: \(error.localizedDescription)")
    }
}

// MARK: - Example 2: Combine Pattern

print("\n2️⃣ COMBINE PATTERN\n")

var cancellables = Set<AnyCancellable>()

getUsersUseCase.executePublisher()
    .flatMap { users -> AnyPublisher<[Post], NetworkError> in
        print("✅ Fetched \(users.count) users (Combine)")
        if let firstUser = users.first {
            print("   First user: \(firstUser.name) (\(firstUser.email))")
            return getUserPostsUseCase.executePublisher(userId: firstUser.id)
        } else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
    }
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("   Combine stream completed successfully")
            case .failure(let error):
                print("❌ Combine error: \(error.localizedDescription)")
            }
        },
        receiveValue: { posts in
            print("✅ Fetched \(posts.count) posts (Combine)")
            if let firstPost = posts.first {
                print("   First post: \(firstPost.title)")
            }
        }
    )
    .store(in: &cancellables)

// MARK: - Example 3: Async/Await Pattern

print("\n3️⃣ ASYNC/AWAIT PATTERN\n")

Task {
    do {
        let users = try await getUsersUseCase.executeAsync()
        print("✅ Fetched \(users.count) users (Async/Await)")

        if let firstUser = users.first {
            print("   First user: \(firstUser.name) (\(firstUser.email))")

            let posts = try await getUserPostsUseCase.executeAsync(userId: firstUser.id)
            print("✅ Fetched \(posts.count) posts for user \(firstUser.name)")

            if let firstPost = posts.first {
                print("   First post: \(firstPost.title)")
            }
        }
    } catch {
        print("❌ Async/Await error: \(error.localizedDescription)")
    }
}

// MARK: - Example 4: Parallel Requests with Async/Await

print("\n4️⃣ PARALLEL REQUESTS (Async/Await)\n")

Task {
    do {
        // Fetch multiple users in parallel
        async let user1 = userRepository.getUserAsync(id: 1)
        async let user2 = userRepository.getUserAsync(id: 2)
        async let user3 = userRepository.getUserAsync(id: 3)

        let users = try await [user1, user2, user3]
        print("✅ Fetched \(users.count) users in parallel")
        users.forEach { user in
            print("   - \(user.name) (\(user.email))")
        }
    } catch {
        print("❌ Parallel fetch error: \(error.localizedDescription)")
    }
}

// MARK: - Example 5: Error Handling

print("\n5️⃣ ERROR HANDLING EXAMPLE\n")

Task {
    do {
        // This will fail with 404
        let _ = try await userRepository.getUserAsync(id: 99999)
    } catch let error as NetworkError {
        print("❌ Caught NetworkError: \(error.localizedDescription)")
    } catch {
        print("❌ Caught unknown error: \(error.localizedDescription)")
    }
}

// Keep playground running to see async results
PlaygroundPage.current.needsIndefiniteExecution = true

print("\n⏳ Waiting for network requests to complete...\n")

/*
 ## Key Takeaways

 ### Clean Architecture Benefits Demonstrated

 ✅ **Testability**
    - All layers tested in isolation
    - Mock implementations for fast, reliable tests
    - No need for actual network calls in tests

 ✅ **Flexibility**
    - Easy to swap from one async pattern to another
    - Can change API client implementation without touching use cases
    - Can add caching, offline support without refactoring

 ✅ **Separation of Concerns**
    - Models: Pure data structures
    - Network Layer: HTTP communication
    - Repository: Data access abstraction
    - Use Cases: Business logic
    - Each layer has one job and does it well

 ✅ **Dependency Inversion**
    - High-level modules (use cases) don't depend on low-level modules (network)
    - Both depend on abstractions (protocols)
    - Enables dependency injection for testing and flexibility

 ### When to Use This Architecture

 **Good For:**
 - Medium to large applications
 - Apps with complex business logic
 - Projects with multiple developers
 - Apps requiring high test coverage
 - Long-term maintenance projects

 **Overkill For:**
 - Simple CRUD apps with minimal logic
 - Prototypes and MVPs
 - Apps with 1-2 screens
 - Learning projects (unless learning architecture!)

 ### Next Steps

 To apply this architecture in your app:

 1. Define your domain models (pure Swift structs/classes)
 2. Create network error types and API client
 3. Define repository protocols for each entity
 4. Implement repositories using the network layer
 5. Create use cases for specific user actions
 6. Inject dependencies from the app's composition root
 7. Write unit tests for each layer

 ### Further Reading

 - Clean Architecture by Robert C. Martin
 - SOLID Principles
 - Dependency Injection in iOS
 - Repository Pattern
 - Swift Concurrency (async/await)
 - Combine Framework
 */
