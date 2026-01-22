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

// MARK: - Protocol Definition

/// A protocol that defines a color theme contract.
///
/// Any type conforming to this protocol must provide three colors:
/// primary, secondary, and tertiary. These properties are read-only
/// computed properties (get-only), meaning conforming types can implement
/// them as either stored or computed properties.
///
/// Example usage:
/// ```
/// struct MyTheme: ColorThemeProtocol {
///     var primary: Color { .blue }
///     var secondary: Color { .white }
///     var tertiary: Color { .gray }
/// }
/// ```
protocol ColorThemeProtocol {
    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
}

// MARK: - Theme Implementations

/// Default color theme with vibrant primary colors.
///
/// Implements ColorThemeProtocol using stored properties.
/// This demonstrates that protocol requirements can be satisfied
/// with constant stored properties.
struct DefaultColorTheme: ColorThemeProtocol {
    let primary: Color = .red
    let secondary: Color = .blue
    let tertiary: Color = .green
}

/// Alternative color theme with warm tones.
///
/// Second implementation of ColorThemeProtocol showing how multiple
/// types can conform to the same protocol with different values.
struct AlternativeColorTheme: ColorThemeProtocol {
    let primary: Color = .yellow
    let secondary: Color = .orange
    let tertiary: Color = .brown
}

/// Third color theme with neutral and dark colors.
///
/// Another conforming implementation demonstrating the flexibility
/// of protocols to support various color schemes.
struct TerternativeColorTheme: ColorThemeProtocol {
    let primary: Color = .black
    let secondary: Color = .gray
    let tertiary: Color = .purple
}

// MARK: - Data Source Protocol

/// A protocol defining a data source contract for text content.
///
/// This demonstrates a simpler protocol with a single property requirement.
/// Unlike ColorThemeProtocol which uses structs, this example shows how
/// protocols work equally well with classes.
///
/// Key differences from ColorThemeProtocol:
/// - Single property requirement vs. three
/// - Implemented by classes (reference types) vs. structs (value types)
/// - Mutable property (var) demonstrating runtime changes
protocol DataSourceProtocol {
    var text: String { get }
}

/// Default implementation of DataSourceProtocol.
///
/// Uses a class (reference type) to conform to the protocol.
/// The text property is mutable, allowing the data source to be updated
/// after initialization. This showcases how protocols don't dictate
/// whether conforming types should be classes or structs.
class DefaultDataSource: DataSourceProtocol {
    var text: String = "Hello, World! from DefaultDataSource"
}

/// Alternative implementation of DataSourceProtocol.
///
/// Provides different default text while maintaining the same contract.
/// This demonstrates how multiple classes can conform to the same protocol
/// with different implementations, enabling polymorphic behavior.
class AlternativeDataSource: DataSourceProtocol {
    var text: String = "Hello, World! from AlternativeDataSource"
}

// MARK: - Protocol Usage Example

/// Demonstrates protocol-based dependency injection and polymorphism.
///
/// This struct doesn't care about the concrete type of the color theme.
/// It only cares that it conforms to ColorThemeProtocol. This allows:
/// - Easy theme switching without code changes
/// - Testing with mock themes
/// - Loose coupling between components
///
/// The colorTheme property type is the protocol, not a concrete type.
/// This is the essence of protocol-oriented programming.
struct ProtocolsBootcamp {

    /// Color theme instance conforming to ColorThemeProtocol.
    /// Could be any type that implements the protocol.
    let colorTheme: ColorThemeProtocol = DefaultColorTheme()

    /// Data source instance conforming to DataSourceProtocol.
    /// Demonstrates using multiple protocols together for composition.
    /// Could be swapped with AlternativeDataSource without changing code.
    let dataSource: DataSourceProtocol = DefaultDataSource()

    /// Creates a text view styled with protocol-defined colors and content.
    ///
    /// This method demonstrates protocol composition by using:
    /// - `dataSource.text` for the content (from DataSourceProtocol)
    /// - `colorTheme.primary` for styling (from ColorThemeProtocol)
    ///
    /// Neither the data source nor theme concrete types are known here,
    /// only their protocol contracts. This enables flexible, testable code.
    func start() {
        Text(dataSource.text)
            .foregroundColor(colorTheme.primary)
    }
}

// MARK: - Execution

/// Create an instance and invoke the start method.
/// The Text view will be styled with the red color from DefaultColorTheme.
///
/// To change themes, simply replace DefaultColorTheme() with:
/// - AlternativeColorTheme() for warm tones
/// - TerternativeColorTheme() for neutral/dark colors
let x = ProtocolsBootcamp()
x.start()

// MARK: - Advanced Example: Dynamic Theme Switching

/// Demonstrates how protocols enable flexible, type-safe theme management.
///
/// This function accepts any type conforming to ColorThemeProtocol,
/// allowing us to pass different theme implementations at runtime.
func displayWithTheme(_ theme: ColorThemeProtocol) {
    print("Primary: \(theme.primary)")
    print("Secondary: \(theme.secondary)")
    print("Tertiary: \(theme.tertiary)")
    print("---")
}

// Test all three themes using the same function
print("Testing different themes:")
displayWithTheme(DefaultColorTheme())
displayWithTheme(AlternativeColorTheme())
displayWithTheme(TerternativeColorTheme())

// MARK: - Protocol Extensions Example

/// Protocol extensions allow you to provide default implementations.
extension ColorThemeProtocol {
    /// Provides a computed property available to all conforming types.
    /// This doesn't need to be implemented by each theme.
    var allColors: [Color] {
        [primary, secondary, tertiary]
    }

    /// Method available to all themes without individual implementation.
    func printTheme() {
        print("Theme colors: \(allColors)")
    }
}

// Now all themes automatically have these methods
print("\nUsing protocol extension:")
let defaultTheme = DefaultColorTheme()
defaultTheme.printTheme()
print("Color count: \(defaultTheme.allColors.count)")

// MARK: - Protocol Composition Example

/// Demonstrates using multiple protocols together.
///
/// This function accepts both protocols as parameters, showing how
/// protocols can be composed to build flexible, reusable components.
/// Neither concrete type is specified - only the protocol contracts.
func createStyledView(
    theme: ColorThemeProtocol,
    dataSource: DataSourceProtocol
) {
    print("\nCreating view with:")
    print("- Text: \(dataSource.text)")
    print("- Primary Color: \(theme.primary)")
}

// Test different combinations of themes and data sources
print("\nTesting protocol composition:")
createStyledView(theme: DefaultColorTheme(), dataSource: DefaultDataSource())
createStyledView(theme: AlternativeColorTheme(), dataSource: AlternativeDataSource())
createStyledView(theme: TerternativeColorTheme(), dataSource: DefaultDataSource())

// MARK: - Key Takeaways

/*
 PROTOCOL BEST PRACTICES:

 1. SINGLE RESPONSIBILITY
    Each protocol should define one cohesive set of requirements.
    Example: ColorThemeProtocol focuses only on colors.

 2. COMPOSITION OVER INHERITANCE
    Combine multiple protocols instead of creating complex hierarchies.
    Example: ProtocolsBootcamp uses both ColorTheme and DataSource protocols.

 3. PROTOCOL EXTENSIONS FOR DEFAULTS
    Provide default implementations to reduce boilerplate.
    Example: allColors and printTheme() added via extension.

 4. DEPENDENCY INJECTION
    Accept protocols as parameters, not concrete types.
    Example: createStyledView() accepts protocol types.

 5. VALUE VS REFERENCE TYPES
    Protocols work with both structs and classes.
    Example: ColorTheme uses structs, DataSource uses classes.

 WHEN TO USE PROTOCOLS:
 - When multiple types need to share behavior
 - For dependency injection and testability
 - To enable polymorphism without inheritance
 - When designing flexible, extensible APIs
 */

