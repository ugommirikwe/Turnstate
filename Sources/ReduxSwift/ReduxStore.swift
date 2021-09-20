import Foundation

/// The Redux store brings together the state, actions, and reducers that make up your app.
///
/// The store has several responsibilities:
/// - Holds the current application [state](x-source-tag://State) as a tree of read-only properties;
/// - Allows access to the current state via `store.getState()`;
/// - Allows state to be updated via `store.dispatch(action)`;
/// - Registers listener callbacks via `store.subscribe(listener)`;
/// - Handles unregistering of listeners via the unsubscribe function returned by `store.subscribe(listener)`.
///
/// It's important to note that you must only have a single instance of this class (store) in your application. When you want to split your data handling logic, you'll use reducer composition and create multiple [reducers](x-source-tag://Reducer) that can be combined together, instead of creating separate stores.
///
/// Using this class requires associating a concrete implementation of a [state](x-source-tag://State) (representing the current state tree of your application), which conforms to the `Equatable` protocol
///
/// - Tag: ReduxStore
final public class ReduxStore<State: Equatable> {
    
    /// Defines the signature of a pure function that is used to compute a new [state](x-source-tag://State) given the currently existing state and an [action](x-source-tag://StoreActionProtocol) dispatched to the store.
    /// - Tag: Reducer
    public typealias Reducer = (State, StoreActionProtocol) -> State
    
    /// Describes the signature of the function to be passed to the [subscribe](x-source-tag://subscribe)
    /// - Tag: Subscriber
    public typealias Subscriber = [UUID: (State) -> Void]
    
    /// Object representing the current state tree of your application.
    /// - Tag: State
    private var state: State
    
    private let reducers: [Reducer]
    private let middleware: [StoreMiddlewareProtocol]
    private var storeSubscribers: Subscriber = [:]
    
    /// Creates a new instance of this store, provided its dependencies are passed in.
    /// - Parameters:
    ///   - initialState: The initial state to hydrate this store instance with. It must be the same type as defined by the generic [State](x-source-tag://State) object.
    ///   - reducers: A list of [reducers](x-source-tag://Reducer) you can pass to the store to handle changes to different parts of the state (i.e. different properties defined in the [state](x-source-tag://State)). All of these reducers passed in will be invoked for every action dispatched to the store so they can participate in responding to the actions that pertains to the part of the state they are concerned with.
    ///   - middleware: A list of objects that conform to the [StoreMiddlewareProtocol](x-source-tag://StoreMiddlewareProtocol), which provide a way to enhance the store by adding handling async operations (which reducers can't). The store invokes these plugins, allowing them to intercept actions dispatched to the store before they reach the reducers.
    public init(
        initialState: State,
        reducers: [Reducer],
        middleware: [StoreMiddlewareProtocol] = []
    ) {
        self.state = initialState
        self.reducers = reducers
        self.middleware = middleware
    }
    
    /// Returns the current state tree of your application. It is equal to the last value returned by the store's reducers.
    ///
    /// - Returns: The current state tree of your application, which should match the type of [State](x-source-tag://State) object associated with this instance of the [ReduxStore](x-source-tag://ReduxStore).
    /// - Tag: getState
    final public func getState() -> State {
        return self.state
    }
    
    /// Dispatches an action to this store. This is the only way to trigger a state change.
    ///
    /// [Middleware](x-source-tag://StoreMiddlewareProtocol) plugins registered with this [store](x-source-tag://ReduxStore) will first receive the action dispatched before they're eventually passed on to the reducers.
    ///
    /// The store's reducing function will be called with the current getState() result and the given action synchronously. Its return value will be considered the next state. It will be returned from getState() from now on, and the change listeners will immediately be notified.
    ///
    /// - Parameter action: An instance or subset of a concrete type that extends the [StoreActionProtocol](x-source-tag://StoreActionProtocol) in your app.
    ///
    /// - Tag: dispatch
    final public func dispatch(action: StoreActionProtocol) {
        if middleware.isEmpty {
            invokeReducers(with: action)
            return
        }

        var currentIndex = middleware.startIndex
        let endIndex = middleware.endIndex - 1
        var middlewarePluginsCalled: [String] = []

        func run(_ mware: StoreMiddlewareProtocol, _ action: StoreActionProtocol, _ index: Int) {
            mware.run(
                store: (dispatch, getState),
                next: { [weak self] ac in
                    guard let self = self else { return }
                    
                    let typeName = String(describing: mware)
                    if middlewarePluginsCalled.contains(typeName) {
                        return
                    }
                    middlewarePluginsCalled.append(typeName)
                    
                    currentIndex = index.advanced(by: 1)
                    if currentIndex > endIndex {
                        self.invokeReducers(with: action)
                        return
                    }
                    
                    run(self.middleware[currentIndex], ac , currentIndex)
                },
                action: action
            )
        }
        
        run(middleware.first!, action, 0)
    }
    
    /// Adds a change listener. It will be called any time an action is dispatched, and some part of the state tree may potentially have changed. You may then call [getState()](x-tag://getState) to read the current state tree inside the callback.
    /// - Parameter listener: The callback to be invoked any time an action has been dispatched, and the state tree might have changed. Its signature is defined by the [Subscriber](x-source-tag://Subscriber) typealias.
    ///
    /// - Returns: A function that unsubscribes the change listener.
    /// - Tag: subscribe
    final public func subscribe(_ listener: Subscriber) -> () -> Void {
        for (key, callback) in listener {
            storeSubscribers.updateValue(callback, forKey: key)
            callback(getState())
        }
        
        return { [weak self, listener] in
            for (key, _) in listener {
                self?.storeSubscribers.removeValue(forKey: key)
            }
        }
    }
    
    private func invokeSubscribers() {
        for (_, subscriptionListener) in storeSubscribers {
            subscriptionListener(self.state)
        }
    }
    
    private func invokeReducers(with action: StoreActionProtocol) {
        if self.reducers.isEmpty { return }
        
        let oldState = self.state
        
        for reducer in self.reducers {
            self.state = reducer(self.state, action)
        }
        
        if self.state != oldState {
            invokeSubscribers()
        }
    }
}
