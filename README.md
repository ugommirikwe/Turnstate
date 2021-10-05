# Turnstate

![Build Status](https://github.com/ugommirikwe/turnstate/actions/workflows/swift.yml/badge.svg)

A minimalist predictable state management library for Swift apps, modeled after [ReduxJS](https://redux.js.org). It is deliberately very similar to ReduxJS so much so that it mirrors much of ReduxJS APIs, like the store object methods: `getState()`, `dispatch()`, `subscribe()` and `combineReducers()`. It also adopts the middleware system for asynchronous data flow management that ReduxJS  uses, complete with similar API. If you're familiar with using ReduxJS, you should be easily familiar with Turnstate; in fact, thanks to the Swift language and its strong typing system, Turnstate offers a smoother and more fluent ergonomics than ReduxJS! I promise ya :-)

Unlike other similar Redux-like or unidirectional data-flow state management frameworks and libraries created for Swift platforms, this library is completely independent of any reactive libraries (or any other non-standard Swift library dependencies), like RxSwift or Combine. Which means it can be used for any form of Swift app development, including for UIKit, AppKit, SwiftUI, Catalyst, Linux, etc. It also means this library backward compatible with OS versions up to iOS 8.

The name "Turnstate" is an amalgalm of the words "state" and "turnstile"--which is defined by Wikipedia "as a form of gate which allows one person to pass at a time. It can also be made so as to enforce one-way human traffic, and in addition, it can restrict passage only to people who insert a coin, a ticket, a pass, or similar."

## Store

At the core of the library is the [`Store`](Sources/Turnstate/Store.swift) class. This brings together the state, actions, middleware and reducers that participate in managing data and its flow to and fro the components of your application.

The store has several responsibilities:
- Holds the current application state (which is prescribed to be in the form of a struct with a tree of read-only properties);
- Allows access to this state via the `getState()` instance method;
- Registers state "reducer" functions, which are the only way to update the state.
- Allows state to be updated via the `dispatch(action)` instance method, which invokes registered middleware plugins and, subsequently, reducers, passing along the action dispatched and the current state;
- Registers listener callbacks via `subscribe(listener)` instant method;
- Handles unregistering of listeners via the unsubscribe function returned by `subscribe(listener)` instance method.

It's important to note that you must only have a single instance of this class in your application. When you want to split your data handling logic, you'll use reducer composition and create multiple reducer functions that can be combined together, instead of creating separate stores.

Whereas, in ReduxJS, a store is created with a call to the function `createStore`, in Turnstate an instance of a store is created via its `init`ializer, like so:

```
let store: Store<AppState> = Store(
    initialState: AppState(...),
    rootStateReducer: combineReducers(reducer1, reducer2, ...),
    middleware: [middleware1, middleware2, ...]
)
```

## State
Object representing the current state tree of your application. The Turnstate library requires that a root state be created and associated, via a generic parameter, with an instance of a [Store](). This root state must conform to the [RootStateProtocol](Sources/Turnstate/RootStateProtocol.swift).

The [RootStateProtocol](Sources/Turnstate/RootStateProtocol.swift) defines a type for the tree of data that constitutes the state of applications that use this library. Apps should declare conforming types as `struct`s and the type's properties should be made immutable by declaring them with  `private(set) var` while setting initial/default values. The only way to change the values of the properties will be through `reducer` functions registered with the instance of the [Store](Sources/Turnstate/Store.swift) that the conforming state is associated with.

This protocol also provides a helper `copy` function that makes it easier for `reducer` functions to clone existing state and modify relevant properties in a fluid syntax.

## Action
An action represents an object describing a change, alongside any associated piece of data (usually referred to as its payload), that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions--i.e. invoking the `dispatch(action)` method of the store instance and passing in the action object.

Turnstate defines the [StoreActionProtocol](Sources/Turnstate/StoreActionProtocol.swift) as a base type for actions that can be dispatched in an instance of the [`Store` (store)](Sources/Turnstate/Store.swift) class. Apps must create an `enum` that extends this protocol and then define cases inside of the enum that represents the actions that can be dispatched to the store. For example:

```
enum Action: StoreActionProtocol {
    case UserCreateRequested(User)
}
```

where `UserCreateRequested` is the type of the action to be dispatched for creating a `User` object that is passed as a payload.

## Middleware
Very similar to the [Redux JS Middleware System](https://redux.js.org/tutorials/fundamentals/part-4-store#middleware), this provides a mechanism for attaching functionality to an app in a composable manner. It is also the only way to handle asynchronous operations in order to process `action`s dispatched to the store.

Middleware plugins sit between the store and state reducers defined for the store. The plugins first receive actions dispatched to the store, which they then handle (if they are interested in the action) and then passed along in the chain of plugins registered in the store, at the end of which the actions are then passed to the registered state reducers.

Middleware plugins must be defined as (only) classes that conform to the [StoreMiddlewareProtocol](Sources/Turnstate/StoreMiddlewareProtocol.swift). Dependencies required for the plugins' operations should be injected via the `init`ializer for the plugin classes (and stored in private properties to be reused, throughout the lifecycle of the plugins' instances, for every action the plugins are interested in).

The [StoreMiddlewareProtocol](Sources/Turnstate/StoreMiddlewareProtocol.swift) defines a `run` function which the [Store](Sources/Turnstate/Store.swift) instance, which the middleware plugin is registered with, invokes to execute the plugin. This `run` function has the following signature:

```
func run(
    store: StoreAPI,
    next: @escaping (_ a: StoreActionProtocol) -> Void,
    action: StoreActionProtocol
)
```

where 
- the `store` parameter is of type `StoreAPI`, a typealias for a Swift tuple containing two functions: the `dispatch` and `getState` functions, which are passed in by the [Store](Sources/Turnstate/Store.swift) instance that this middleware plugin is registered with. These are the same `dispatch` and `getState` functions that are actually part of the store. Important to note: The `storeAPI.dispatch` should be used to send a new action to the `store`, while `next` function (below) is used to continue the passed-in `action` along the chain of middleware plugins.

   The `storeAPI.getState` function returns the current state of the application held in the [Store](Sources/Turnstate/Store.swift).

- the `next` parameter defines a function to invoke in order to pass-on the currently dispatched `action` to the next plugin in the chain of middleware plugins registered with the [Store](Sources/Turnstate/Store.swift). This must be called just once at the end of this function to signal that the plugin is done with its operations. The `next` function signature defines a `StoreActionProtocol` parameter with which it expects to receive the currently dispatched `action`.

- Lastly, the `action` parameter defines the action currently dispatched to the store.

## Reducer
It's important to note that you must only have a single instance of the [Store](Sources/Turnstate/Store.swift) class in your application. When you want to split your data handling logic, you'll use reducer composition and create multiple `reducer` functions that can be combined together, instead of creating separate stores.

A `reducer` function is really a pure function that is used to compute a new `state` given the currently existing state and an `action` dispatched to the store.

The Turnstate library expects `reducer` functions to have a signature like so:

```
(RootStateProtocol, StoreActionProtocol) -> RootStateProtocol
```

Essentially, the `reducer` function will expect the current `state` object, which conforms to the [RootStateProtocol](Sources/Turnstate/RootStateProtocol.swift), and an `action` object, which conforms to the [StoreActionProtocol](Sources/Turnstate/StoreActionProtocol.swift), dispatched to the `store`, and then return a new (or, if the reducer isn't interested in this action, returns the same) `state` object.

### `combineReducers`
The Turnstate library provides a helper function that turns a list of different reducing functions into a single reducing function you can pass to the store `init`ializer. The resulting reducer calls every child reducer, and gathers their results to update the root state object. This function helps you organize your reducers to manage their own slices of state.
