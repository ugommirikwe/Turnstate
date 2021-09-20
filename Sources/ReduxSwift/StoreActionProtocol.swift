import Foundation

/// Defines a type for actions that can be dispatched in an instance of a [store](x-source-tag://ReduxStore). Apps must create an `enum` that extends this protocol and then define cases inside of the enum that represents the actions that can be dispatched to the [store](x-source-tag://ReduxStore).
///
/// An action represents an object describing a change, alongside any associated piece of data, that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
/// 
/// - Tag: StoreActionProtocol
public protocol StoreActionProtocol {}
