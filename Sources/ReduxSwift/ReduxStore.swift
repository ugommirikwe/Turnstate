//
//  File.swift
//  
//
//  Created by Ugochukwu Mmirikwe on 2021/08/18.
//

import Foundation

final public class ReduxStore<State: Equatable, StoreAction> {
    public typealias Reducer = (State, StoreAction) -> State
    public typealias Subscriber = [UUID: (State) -> Void]
    public typealias Middleware = (_ store: ReduxStore, _ next: @escaping (StoreAction) -> Void, _ action: StoreAction) -> Void
    
    private var state: State
    private let middleware: [Middleware]
    private let reducers: [Reducer]
    private var storeSubscribers: Subscriber = [:]
    
    public init(
        initialState: State,
        reducers: [Reducer],
        middleware: [Middleware] = []
    ) {
        self.state = initialState
        self.reducers = reducers
        self.middleware = middleware
    }
    
    final public func getState() -> State {
        return self.state
    }
    
    final public func subscribe(_ listener: Subscriber) -> () -> Void {
        for (key, value) in listener {
            storeSubscribers.updateValue(value, forKey: key)
        }
        
        return { [weak self, listener] in
            for (key, _) in listener {
                self?.storeSubscribers.removeValue(forKey: key)
            }
        }
    }
    
    final public func dispatch(action: StoreAction) {
        if middleware.isEmpty {
            invokeReducers(with: action)
            return
        }

        var currentIndex = middleware.startIndex
        let endIndex = middleware.endIndex - 1
        var middlewarePluginsCalled: [String] = []

        func run(_ mware: @escaping Middleware, _ action: StoreAction, _ index: Int) {
            mware(
                self,
                { [weak self] ac in
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
                    
                    run(self.middleware[currentIndex], ac, currentIndex)
                },
                action
            )
        }
        
        run(middleware.first!, action, 0)
    }
    
    private func invokeSubscribers() {
        for (_, subscriptionListener) in storeSubscribers {
            subscriptionListener(self.state)
        }
    }
    
    private func invokeReducers(with action: StoreAction) {
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
