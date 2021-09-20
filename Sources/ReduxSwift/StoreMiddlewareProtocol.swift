import Foundation

/// Defines a protocol for middleware plugins that can be registered with a [Store](x-source-tag://ReduxStoreProtocol) instance.
///
/// Very similar to the [Redux Middleware System](https://redux.js.org/tutorials/fundamentals/part-4-store#middleware), this provides a mechanism for attaching functionality to an app in a composable manner. It is also the only way to handle asynchronous operations in order to process [action](x-source-tag://StoreActionProtocol)s  [dispatch](x-source-tag://dispatch)ed in the store.
///
/// Middleware plugins are defined by comforming to this protocol. Dependencies required for the plugins' operations should be defined and received as arguments in `init` function for the plugins and held in local properties to be reused for every action the plugins are interested in.
///
/// Middleware plugins sit between the store and state reducers defined for the store. The plugins first receive actions dispatched to the store, which they then handle (if they are interested in the action) and then passed along in the chain of plugins registered in the store.
///
/// - Tag: StoreMiddlewareProtocol
public protocol StoreMiddlewareProtocol: AnyObject {
    /// Executes this middleware. Use `next` to continue the passed-in `action`, but use` store.dispatch` to send a new action to the `store`.
    /// - Parameters:
    ///   - store: Store instance.
    ///   - next: Function to invoke to pass-on the current action to the next plugin in the chain of middleware plugins registered with the store.
    ///   - action: The `next` function has to be passed the current [Action] (x-source-tag://StoreActionProtocol)
    ///   - action: The current [Action](x-source-tag://StoreActionProtocol) dispatched to the store.
    /// - Tag: run
    func run<Store: ReduxStoreProtocol>(
        store: Store,
        next: @escaping (_ action: StoreActionProtocol) -> Void,
        action: StoreActionProtocol
    )
}
