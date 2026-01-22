/*
 
 
 
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

