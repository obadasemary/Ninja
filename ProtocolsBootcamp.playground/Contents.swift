/*
 PROTOCOLS BOOTCAMP

 Protocols define a blueprint of methods, properties, and requirements that suit
 a particular task or piece of functionality. They can be adopted by classes,
 structs, and enums to provide actual implementations.

 KEY CONCEPTS:
 - Protocols define requirements (properties, methods) without implementation
 - Types that adopt protocols must implement all required members
 - Protocols enable polymorphism and dependency injection
 - Multiple protocols can be adopted by a single type
 - Protocol-oriented programming is a key Swift paradigm

 BENEFITS:
 1. Code Reusability: Common behavior across different types
 2. Testability: Easy to create mock implementations
 3. Flexibility: Swap implementations without changing dependent code
 4. Type Safety: Compiler ensures protocol requirements are met

 This playground demonstrates:
 - Defining a protocol with read-only computed properties
 - Creating multiple conforming types (themes)
 - Using protocol as a type for dependency injection
 - Polymorphic behavior through protocol abstraction
 */

import SwiftUI

var greeting = "Hello, playground"

protocol ColorThemeProtocol {
    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
}

struct DefaultColorTheme: ColorThemeProtocol {
    let primary: Color = .red
    let secondary: Color = .blue
    let tertiary: Color = .green
}

struct AlternativeColorTheme: ColorThemeProtocol {
    let primary: Color = .yellow
    let secondary: Color = .orange
    let tertiary: Color = .brown
}

struct TerternativeColorTheme: ColorThemeProtocol {
    let primary: Color = .black
    let secondary: Color = .gray
    let tertiary: Color = .purple
}

struct ProtocolsBootcamp {
    
    let colorTheme: ColorThemeProtocol = DefaultColorTheme()
    
    func start() {
        Text("Hello from Protocols Bootcamp!")
            .foregroundColor(colorTheme.primary)
    }
}

let x = ProtocolsBootcamp()
x.start()

