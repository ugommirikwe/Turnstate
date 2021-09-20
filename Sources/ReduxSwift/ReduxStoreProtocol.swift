import Foundation

/// Defines a type for this library's implementation of a Redux-like Store.
///
/// IMPORTANT: This protocol is meant to be used as a type wherever necessary in client code, but not to be implemented in client code.
///
/// Using this protocol as a type, or implementing a type to conform to it, requires associating a concrete implementation of a [state](x-source-tag://State) (representing the current state tree of your application), which conforms to the `Equatable` protocol, as well as a  [StoreActionProtocol](x-source-tag://StoreActionProtocol)-conforming type.
/// - Tag: ReduxStoreProtocol
public protocol ReduxStoreProtocol {
    
    /// Object representing the current state tree of your application.
    /// - Tag: State
    associatedtype State: Equatable
    
    /// This protocol expects a concrete implementation of the [StoreActionProtocol](x-source-tag://StoreActionProtocol) to be associated with this protocol's conforming type.
    /// - Tag: StoreAction
    associatedtype StoreAction: StoreActionProtocol
    
    /// Describes the signature of the function to be passed to the [subscribe](x-source-tag://subscribe)
    /// - Tag: Subscriber
    typealias Subscriber = [UUID: (State) -> Void]

    
    /// Returns the current state tree of your application. It is equal to the last value returned by the store's reducers.
    ///
    /// - Returns: The current state tree of your application, which should match the type of [State](x-source-tag://State) object associated with this conforming instance of the [ReduxStoreProtocol](x-source-tag://ReduxStoreProtocol).
    /// - Tag: getState
    func getState() -> State
    
    /// Dispatches an action. This is the only way to trigger a state change.
    ///
    /// Any [middleware](x-source-tag://StoreMiddlewareProtocol) plugins registered with this [store](x-source-tag://ReduxStoreProtocol) will first receive the action dispatched before they're eventually passed on to the reducers.
    ///
    /// The store's reducing function will be called with the current getState() result and the given action synchronously. Its return value will be considered the next state. It will be returned from getState() from now on, and the change listeners will immediately be notified.
    ///
    /// - Parameter action: An object describing the change that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from the UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
    /// - Tag: dispatch
    func dispatch(action: StoreAction)
    
    /// Adds a change listener. It will be called any time an action is dispatched, and some part of the state tree may potentially have changed. You may then call [getState()](x-tag://getState) to read the current state tree inside the callback.
    /// - Parameter listener: The callback to be invoked any time an action has been dispatched, and the state tree might have changed. Its signature is defined by the [Subscriber](x-source-tag://Subscriber) typealias.
    ///
    /// - Returns: A function that unsubscribes the change listener.
    /// - Tag: subscribe
    func subscribe(_ listener: Subscriber) -> () -> Void
}
