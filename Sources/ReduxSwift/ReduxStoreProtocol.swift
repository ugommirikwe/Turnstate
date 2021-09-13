import Foundation

/// Defines a type for this library's implementation of a Redux-like Store.
public protocol ReduxStoreProtocol {
    /// The current state tree of your application.
    associatedtype State: Equatable & Codable
    
    /// An object describing the change that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from the UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
    associatedtype StoreAction
    
    typealias Subscriber = [UUID: (State) -> Void]

    
    /// Returns the current state tree of your application. It is equal to the last value returned by the store's reducer.
    /// - Returns: The current state tree of your application.
    /// - Tag: getState
    func getState() -> State
    
    /// Dispatches an action. This is the only way to trigger a state change.
    ///
    /// The store's reducing function will be called with the current getState() result and the given action synchronously. Its return value will be considered the next state. It will be returned from getState() from now on, and the change listeners will immediately be notified.
    /// - Parameter action: An object describing the change that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from the UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
    func dispatch(action: StoreAction)
    
    /// Adds a change listener. It will be called any time an action is dispatched, and some part of the state tree may potentially have changed. You may then call [getState()](x-tag://getState) to read the current state tree inside the callback.
    /// - Parameter listener: The callback to be invoked any time an action has been dispatched, and the state tree might have changed.
    /// - Returns: A function that unsubscribes the change listener.
    /// - Tag: subscribe
    func subscribe(_ listener: Subscriber) -> () -> Void
}
