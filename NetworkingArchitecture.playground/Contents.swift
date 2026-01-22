import Foundation
import Combine
import PlaygroundSupport

// MARK: - Models

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let username: String
}

struct Post: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// MARK: - Network Error

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

// MARK: - Network Layer (API Client)

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

class APIClient: NetworkServiceProtocol {
    private let baseURL = "https://jsonplaceholder.typicode.com"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Completion Handler Implementation

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

class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

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

class GetUsersUseCase: GetUsersUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol

    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }

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

// MARK: - Unit Tests

import XCTest

// MARK: - Mock Network Service

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
