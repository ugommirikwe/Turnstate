import Foundation

/// Defines a type for the tree of data that constitutes the state of applications that use this library.
///
/// Apps should declare conforming types as `struct`s and the type's properties should be made immutable by declaring them with  `private(set) var` while setting initial/default values. The only way to change the values of the properties will be through ``Reducer`` functions registered with the instance of the ``Store`` that the conforming state is associated with.
///
/// This protocol also provides a helper [`copy`](x-source-tag://copy) function that makes it easier for ``Reducer`` functions to clone existing state and modify relevant properties in a fluid syntax.
///
/// - Tag: StoreStateProtocol
public protocol StoreStateProtocol: Equatable {}

extension StoreStateProtocol {
    
    /// Enables cloning the current state tree and modifying its readonly properties in a fluid syntax. This function is inspired by the [Kotlin data class `copy` function](https://kotlinlang.org/docs/data-classes.html#copying).
    ///
    /// This function can be used in the following manner:
    ///
    /// ```
    /// struct User {
    ///     private(set) var name: String
    ///     private(set) var age: Int
    ///     private(set) var emailAddress: String
    ///     private(set) var newsLetterSignup: Bool = false
    /// }
    ///
    /// let firstUser = User(
    ///     name: "Rebecca Smith",
    ///     age: 26,
    ///     emailAddress: "r.smith@email.com",
    ///     newsLetterSignup: true
    /// )
    ///
    /// let secondUser = firstUser
    ///     .copy(updating: \.name, to: "George Okon")
    ///     .copy(updating: \.emailAddress, to: "george@okon.com")
    ///
    /// print("\(secondUser)")
    /// // User(name: "George Okon", age: 26, emailAddress: "george@okon.com", newsLetterSignup: true)
    /// ```
    ///
    /// - Parameters:
    ///   - updating: A ``PartialKeyPath`` object, which indicates the property to be modified.
    ///   - to: Value to assign to the property.
    ///
    /// - Returns: A copy of the state object it is called on, with new value assigned to property indicated for the `updating` ``KeyPath`` parameter.
    ///
    /// - Tag: copy
    public func copy<T>(updating keyPath: PartialKeyPath<Self>, to value: T) -> Self {
        var s = self
        s[keyPath: keyPath as! WritableKeyPath<Self, T>] = value
        return s
    }
}
