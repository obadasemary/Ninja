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
