import UIKit

var greeting = "Hello, playground"

// MARK: - Protocol-Oriented Programming Demo

/// A protocol defining the basic operations of a vehicle.
///
/// This protocol demonstrates Swift's protocol-oriented programming paradigm,
/// showing how protocols can define behavior contracts for conforming types.
protocol Vehicle {
    /// Starts the vehicle's engine
    func startEngine()

    /// Stops the vehicle's engine
    func stopEngine()
}

/// Extension providing default implementations for the Vehicle protocol.
///
/// This extension demonstrates:
/// - Default protocol implementations that can be overridden
/// - Adding methods to protocols via extensions (honk is not in the protocol definition)
extension Vehicle {
    /// Default implementation for starting the engine
    func startEngine() {
        print("Engine started generically")
    }

    /// A method added via extension, not part of the Vehicle protocol requirements.
    /// This demonstrates protocol extension capabilities in Swift.
    func honk() {
        print("Generic honk")
    }
}

/// A concrete implementation of the Vehicle protocol.
///
/// This class demonstrates method dispatch behavior:
/// - Protocol-defined methods use dynamic dispatch when called on protocol types
/// - Extension methods use static dispatch when called on protocol types
class Car: Vehicle {
    /// Overrides the default startEngine implementation
    func startEngine() {
        print("Car engine started")
    }

    /// Implements the required stopEngine method
    func stopEngine() {
        print("Car engine stopped")
    }

    /// Overrides the honk method from the protocol extension.
    /// Note: This will only be called when the instance is typed as Car, not Vehicle.
    func honk() {
        print("Car honk")
    }
}

// MARK: - Method Dispatch Demonstration

// When typed as Vehicle protocol, uses protocol witness table for dispatch
let vehicle: Vehicle = Car()
vehicle.startEngine()  // Car engine started (dynamic dispatch - calls Car's implementation)
vehicle.honk()         // Generic honk (static dispatch - calls extension implementation)

// When typed as Car class, uses virtual table for dispatch
let car: Car = Car()
car.startEngine()      // Car engine started (calls Car's implementation)
car.honk()             // Car honk (calls Car's implementation)

// MARK: - UIKit Async Image Loading Demo

import PlaygroundSupport
import UIKit
import Network

/// A view controller demonstrating asynchronous image loading in UIKit.
///
/// This example shows:
/// - Custom UIImageView subclass with network loading capabilities
/// - Asynchronous operations using DispatchQueue
/// - Thread-safe UI updates (network on background, UI updates on main)
class MyViewController: UIViewController {
    /// Sample image URL for testing (robot avatar)
    static let url1 = URL(string: "https://robohash.org/x.png")!

    /// Sample image URL for testing (Flickr image)
    static let url2 = URL(string: "https://live.staticflickr.com/65535/53412181911_26e0853f6f_o_d.png")!

    /// Sets up the view hierarchy and initiates image loading.
    ///
    /// Demonstrates proper view controller setup in a playground environment:
    /// - Creates a white background view
    /// - Adds a custom image view with a semi-transparent green background
    /// - Initiates asynchronous image loading on a background queue
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let myImageView = MyImageView()
        myImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        myImageView.backgroundColor = .green.withAlphaComponent(0.3)

        view.addSubview(myImageView)
        self.view = view

        // Load image asynchronously on a background queue
        // Note: Network operations should be performed off the main thread
//        DispatchQueue.global().async {
//            myImageView.setImageWithUrl(url: MyViewController.url1)
//        }
        DispatchQueue.global().async {
            myImageView.setImageWithUrl(url: MyViewController.url2)
        }
    }
}

/// A custom UIImageView subclass with built-in network image loading capabilities.
///
/// This class demonstrates:
/// - URLSession for network requests
/// - Async data fetching with completion handlers
/// - Thread-safe UI updates using DispatchQueue.main
class MyImageView: UIImageView {
    /// Loads and sets an image from a remote URL.
    ///
    /// This method performs the following steps:
    /// 1. Creates a URLSession data task for the given URL
    /// 2. Downloads the image data on a background thread
    /// 3. Converts the data to a UIImage
    /// 4. Updates the image property on the main thread (required for UI updates)
    ///
    /// - Parameter url: The URL of the image to load
    ///
    /// - Note: The actual network request occurs on a background thread managed by URLSession,
    ///   but UI updates are dispatched to the main thread for thread safety.
    func setImageWithUrl(url: URL) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data else { return }
            // Optional: Could implement caching here
//            var dic: [String: Data] = [:]
//            dic[url.absoluteString] = data

            // UI updates must happen on the main thread
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}

// MARK: - Playground Live View Setup

/// Displays the view controller in the playground's live view.
/// This enables interactive preview and testing of UIKit components.
PlaygroundPage.current.liveView = MyViewController()
