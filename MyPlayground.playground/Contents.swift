import UIKit

var greeting = "Hello, playground"

protocol Vehicle {
    func startEngine()
    func stopEngine()
}

extension Vehicle {
    func startEngine() {
        print("Engine started generically")
    }
    
    func honk() {
        print("Generic honk")
    }
}

class Car: Vehicle {
    func startEngine() {
        print("Car engine started")
    }
    
    func stopEngine() {
        print("Car engine stopped")
    }
    
    func honk() {
        print("Car honk")
    }
}

let vehicle: Vehicle = Car()
vehicle.startEngine()  // Car engine started
vehicle.honk()         // Generic honk

let car: Car = Car()
car.startEngine()      // Car engine started
car.honk()             // Car honk

import PlaygroundSupport
import UIKit
import Network

class MyViewController: UIViewController {
  static let url1 = URL(string: "https://robohash.org/x.png")!
  static let url2 = URL(string: "https://live.staticflickr.com/65535/53412181911_26e0853f6f_o_d.png")!
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .white

    let myImageView = MyImageView()
    myImageView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
    myImageView.backgroundColor = .green.withAlphaComponent(0.3)

    view.addSubview(myImageView)
    self.view = view

//    DispatchQueue.global().async {
//      myImageView.setImageWithUrl(url: MyViewController.url1)
//    }
    DispatchQueue.global().async {
      myImageView.setImageWithUrl(url: MyViewController.url2)
    }
  }
}

class MyImageView: UIImageView {
  func setImageWithUrl(url: URL) {
      URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
          guard let data = data else { return }
//          var dic: [String: Data] = [:]
//          dic[url.absoluteString] = data
          DispatchQueue.main.async {
              self.image = UIImage(data: data)
          }
      }.resume()
  }
}

PlaygroundPage.current.liveView = MyViewController()
