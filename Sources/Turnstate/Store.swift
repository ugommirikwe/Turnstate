//
//  Copyright (c) 2021. Ugo Mmirikwe
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// The store brings together the state, actions, middleware and reducers that make up your app.
///
/// The store has several responsibilities:
/// - Holds the current application [state](x-source-tag://StoreStateProtocol) as a tree of read-only properties;
/// - Allows access to the current state via `store.getState()`;
/// - Allows state to be updated via `store.dispatch(action)`;
/// - Registers listener callbacks via `store.subscribe(listener)`;
/// - Handles unregistering of listeners via the unsubscribe function returned by `store.subscribe(listener)`.
///
/// It's important to note that you must only have a single instance of this class (store) in your application. When you want to split your data handling logic, you'll use reducer composition and create multiple [reducers](x-source-tag://Reducer) that can be combined together, instead of creating separate stores.
///
/// Using this class requires associating a concrete implementation of a [state](x-source-tag://RootStateProtocol) (representing the current state tree of your application), which conforms to the `Equatable` protocol
///
/// - Tag: Store
final public class Store<State: StoreStateProtocol> {
    
    /// Describes the signature of the function to be passed to the [subscribe](x-source-tag://subscribe)
    /// - Tag: Subscriber
    public typealias Subscriber = [UUID: (State) -> Void]
    
    /// Object representing the current state tree of your application.
    ///
    /// - Tag: State
    private var state: State
    private var reducers: [Reducer<State>]
    private let middleware: [StoreMiddlewareProtocol]
    private var storeSubscribers: Subscriber = [:]
    
    /// Creates a new instance of this store, provided its dependencies are passed in.
    /// - Parameters:
    ///   - initialState: The initial state to hydrate this store instance with. It must be the same type as defined by the generic [State](x-source-tag://State) object.
    ///   - reducer: A list of [reducers](x-source-tag://Reducer) you can pass to the store to handle changes to different parts of the state (i.e. different properties defined in the [state](x-source-tag://State)). All of these reducers passed in will be invoked for every action dispatched to the store so they can participate in responding to the actions that pertains to the part of the state they are concerned with.
    ///   - middleware: A list of objects that conform to the [StoreMiddlewareProtocol](x-source-tag://StoreMiddlewareProtocol), which provide a way to enhance the store by adding handling async operations (which reducers can't). The store invokes these plugins, allowing them to intercept actions dispatched to the store before they reach the reducers.
    public init(
        initialState: State,
        //reducers: [Reducer<State, Any>],
        reducer: Reducer<State>...,
        middleware: [StoreMiddlewareProtocol] = []
    ) {
        self.state = initialState
        self.reducers = reducer
        self.middleware = middleware
    }
    
    /// Returns the current state tree of your application. It is equal to the last value returned by the store's reducers.
    ///
    /// - Returns: The current state tree of your application, which should match the type of [State](x-source-tag://State) object associated with this instance of the [Store](x-source-tag://Store).
    ///
    /// - Tag: getState
    final public func getState() -> State {
        return self.state
    }
    
    /// Dispatches an action to this store. This is the only way to trigger a state change.
    ///
    /// [Middleware](x-source-tag://StoreMiddlewareProtocol) plugins registered with this [store](x-source-tag://Store) will first receive the action dispatched before they're eventually passed on to the reducers.
    ///
    /// The store's reducing function will be called with the current getState() result and the given action synchronously. Its return value will be considered the next state. It will be returned from getState() from now on, and the change listeners will immediately be notified.
    ///
    /// - Parameter action: An instance or subset of a concrete type that extends the [StoreActionProtocol](x-source-tag://StoreActionProtocol) in your app.
    ///
    /// - Tag: dispatch
    final public func dispatch(_ action: StoreActionProtocol) {
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
    ///
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
    
    private func notifySubscribers() {
        for (_, subscriptionListener) in storeSubscribers {
            subscriptionListener(self.state)
        }
    }
    
    private func invokeReducers(with action: StoreActionProtocol) {
        let oldState = state
        
        reducers.forEach { reducer in
            state = reducer(state, action)
        }
        
        if state != oldState {
            notifySubscribers()
        }
    }
}

/// A helper function that turns a list of different reducing functions into a single reducing function you can pass to the store initializer. The resulting reducer calls every child reducer, and gathers their results to update the root [state](x-source-tag://State) object.
///
/// This function helps you organize your reducers to manage their own slices of state.
///
/// - Parameter reducers: A variadic list of [reducer](x-source-tag://Reducer) functions.
///
/// - Returns: A single reducer function.
///
/// - Tag: combineReducer
public func combineReducers<State: StoreStateProtocol>(
    _ reducers: Reducer<State>...
) -> Reducer<State> {
    return { state, action in
        var newState = state
        reducers.forEach { reducer in
            newState = reducer(newState, action)
        }
        return newState
    }
}

/// Defines the signature of a pure function that is used to compute a new [state](x-source-tag://State) given the currently existing state and an [action](x-source-tag://StoreActionProtocol) dispatched to the store.
///
/// - Tag: Reducer
public typealias Reducer<RootStateProtocol> = (RootStateProtocol, StoreActionProtocol) -> RootStateProtocol
