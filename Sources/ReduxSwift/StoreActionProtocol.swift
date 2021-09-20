import Foundation

/// Serves as type for actions that can be dispatched in a [store](x-source-tag://ReduxStoreProtocol).
///
/// An object describing the change that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from the UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
/// - Tag: StoreActionProtocol
public protocol StoreActionProtocol {}
