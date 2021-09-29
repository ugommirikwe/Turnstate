import Foundation

/// Defines a type for the tree of data that constitutes the state of applications that use this library.
///
/// Apps should declare conforming types as `struct`s and the type's properties should be made immutable by declaring them with  `private(set) var` while setting initial/default values. The only way to change the values of the properties will be through ``Reducer`` functions registered with the instance of the ``Store`` that the conforming state is associated with.
///
/// This protocol also provides a helper [`copy`](x-source-tag://copy) function that makes it easier for ``Reducer`` functions to clone existing state and modify relevant properties in a fluid syntax.
///
/// - Tag: RootStateProtocol
public protocol RootStateProtocol: Equatable {}

extension RootStateProtocol {
    
    /// Enables cloning the current state tree and modifying its readonly properties in a fluid syntax. This function is inspired by the [Kotlin data class `copy` function](https://kotlinlang.org/docs/data-classes.html#copying).
    ///
    /// This function can be used in the following manner:
    ///
    /// ```
    /// struct User {
    ///     let name: String
    ///     let age: Int
    ///     let emailAddress: String
    ///     private(set) newsletterSignup: Bool = false
    /// }
    ///
    /// let firstUser = User(
    ///     name: "Rebecca Smith",
    ///     age: 26,
    ///     emailAddress: "r.smith@email.com",
    ///     newsletterSignup: true
    /// )
    ///
    /// let secondUser = firstUser.copy { existingDetails in
    ///     .init(
    ///         name: "George Okon",
    ///         age: existingDetails.age,
    ///         emailAddress: "george@okon.com"
    ///     )
    /// }
    /// ```
    ///
    /// Notice how the values of properties in the struct being cloned can be extracted from the closure's parameter: `existingDetails.age`.
    ///
    /// Also, because Swift allows declaring initial/default values for memberwise initializers for properties declared with `private(set) var`, you can completely omit setting their values when using this `copy` function and it'll inherit the value already set from the object being copied. This is why the `newsletterSignup` property, in the example above, doesn't need to be set in the example above.
    ///
    /// - Parameter clone: A closure, which is passed the state object this function is called on and which returns a new instance of the object.
    ///
    /// - Returns: A copy of the state object it is called on, alongside new values assigned to properties within the closure.
    ///
    /// - Tag: copy
    func copy(_ clone: @escaping (Self) -> Self) -> Self {
        return clone(self)
    }
}
