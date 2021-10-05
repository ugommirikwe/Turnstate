import Foundation

/// Defines a protocol for middleware plugins that can be registered with a ``Store`` instance.
///
/// Very similar to the [Redux JS Middleware System](https://redux.js.org/tutorials/fundamentals/part-4-store#middleware), this provides a mechanism for attaching functionality to an app in a composable manner. It is also the only way to handle asynchronous operations in order to process [action](x-source-tag://StoreActionProtocol)s  [dispatch](x-source-tag://dispatch)ed in the store.
///
/// Middleware plugins sit between the store and state reducers defined for the store. The plugins first receive actions dispatched to the store, which they then handle (if they are interested in the action) and then passed along in the chain of plugins registered in the store.
///
/// Middleware plugins must be defined by creating (only) classes that conform to this protocol. Dependencies required for the plugins' operations should be injected via the `init` function for the plugin classes (and stored in private properties to be reused, throughout the lifecycle of the plugins' instances, for every action the plugins are interested in).
///
/// - Tag: StoreMiddlewareProtocol
public protocol StoreMiddlewareProtocol: AnyObject {
    
    /// Executes this middleware. Use `next` to continue the passed-in `action`, but use` store.dispatch` to send a new action to the `store`.
    ///
    /// - Parameters:
    ///   - store: An object containing the [`dispatch`](x-source-tag://dispatch) and [`getState`](x-source-tag://getState) functions, which are passed in by the [store](x-source-tag://Store) instance that this middleware plugin is registered with. These are the same `dispatch` and `getState` functions that are actually part of the store. If you call this `dispatch` function, it will send the action to the start of the middleware pipeline. The `getState` function returns the current state of the application held in the store.
    ///   - next: Function to invoke to pass-on the current action to the next plugin in the chain of middleware plugins registered with the store. This must be called just once at the end of this function to signal that the plugin is done with its operations. The `next` function has to be passed the current `action`.
    ///   - action: The current ``StoreActionProtocol`` dispatched to the store.
    ///
    /// - Tag: run
    func run(
        store: StoreAPI,
        next: @escaping (_ a: StoreActionProtocol) -> Void,
        action: StoreActionProtocol
    )
}

/// Defines the signature of the object that encapsulates the functions passed to a middleware plugin from a store instance.
public typealias StoreAPI = (
    dispatch: (StoreActionProtocol) -> Void,
    getState: () -> Any
)
