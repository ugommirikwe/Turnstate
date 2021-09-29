import Foundation

/// Defines a base type for actions that can be dispatched in an instance of a [store](x-source-tag://ReduxStore). An action represents an object describing a change, alongside any associated piece of data (usually referred to as its payload), that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
///
/// Apps must create an `enum` that extends this protocol and then define cases inside of the enum that represents the actions that can be dispatched to the [store](x-source-tag://ReduxStore).
///
/// For example:
///
/// ```
/// enum Action: StoreActionProtocol {
///     case UserCreateRequested(User)
/// }
/// ```
///
/// where `UserCreateRequested` is the type of the action to be dispatched for creating a `User` object that is passed as a payload.
///
/// - Tag: StoreActionProtocol
public protocol StoreActionProtocol {}
