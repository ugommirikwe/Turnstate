//
//  File.swift
//  
//
//  Created by Ugochukwu Mmirikwe on 2021/08/18.
//

import Foundation
import Combine

@available(macOS 10.15, *)
final public class ReduxStore<State>: ObservableObject {
    public typealias Reducer<S> = (S, StoreAction) -> S
    public typealias Listener = [UUID: (State) -> Void]
    
    // TODO: Find a way to allow state modules
    @Published private(set) var state: State
    @Published private var storeActionDispatched: StoreAction? = nil
    
    private let middleware: [StoreMiddlewareProtocol]
    private let reducers: [Reducer<Any>]
    private var storeSubscribers: [UUID: (State) -> Void] = [:]
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        state: State,
        reducers: [Reducer<Any>] = [],
        middlewares: [StoreMiddlewareProtocol] = []
    ) {
        self.state = state
        self.reducers = reducers
        self.middleware = middlewares
        
        subscribeToStoreActionsForReducers()
        subscribeToViewStateReducers()
    }
    
    final public func getState() -> State {
        return self.state
    }
    
    final public func subscribe(_ listener: Listener) -> (Listener) -> Void {
        for (key, value) in listener {
            storeSubscribers.updateValue(value, forKey: key)
        }
        
        func unSubscribe(_ listener: Listener) {
            for (key, _) in listener {
                storeSubscribers.removeValue(forKey: key)
            }
        }
        
        return unSubscribe
    }
    
    final public func dispatch(action: StoreAction) {
        if self.middleware.isEmpty {
            self.storeActionDispatched = action
            
            invokeSubscribers()
            
            return
        }

        var currentIndex = middleware.startIndex
        let endIndex = middleware.endIndex - 1
        var middlewarePluginsCalled: [String] = []

        func run(_ middleware: StoreMiddlewareProtocol, _ action: StoreAction, _ index: Int) {
            middleware.run(
                store: self,
                next: { [weak self] ac in
                    guard let self = self else { return }
                    
                    let typeName = String(describing: middleware)
                    if middlewarePluginsCalled.contains(typeName) {
                        return
                    }

                    middlewarePluginsCalled.append(typeName)

                    currentIndex = index.advanced(by: 1)
                    if currentIndex > endIndex {
                        // Propagate the action to reducers
                        self.storeActionDispatched = action
                        self.invokeSubscribers()
                        return
                    }
                    run(self.middleware[currentIndex], ac, currentIndex)
                },
                action: action
            )
        }
        
        run(middleware.first!, action, 0)
    }
    
    private func invokeSubscribers() {
        for (_, value) in storeSubscribers {
            value(getState())
        }
    }
    
    /// The equivalent of the [Redux connect()](https://react-redux.js.org/api/connect) or
    /// [Redux Hooks](https://react-redux.js.org/api/hooks) APIs, it subscribes to the
    /// Redux store and then runs whenever a store action is dispatched in order to provide view components
    /// with up-to-date pieces of data (i.e. state) from the store that each view component needs to render.
    private func subscribeToStoreActionsForReducers() {
        self.$storeActionDispatched
            .compactMap { $0 }
            .sink { [weak self] storeAction in
                guard let self = self else { return }
                
                if self.reducers.isEmpty { return }
                
                for reducer in self.reducers {
                    self.state = reducer(self.state, storeAction) as! State
                }
            }
            .store(in: &cancellables)
    }
    
    /// Receives notifications of changes in the view states and further propagates them to view components
    /// interested in the changes. This is a work-around for handling SwiftUI view's inability to bind to nested
    /// `ObservableObject`s.
    ///
    /// [See source here.](https://stackoverflow.com/a/58406402/2077405)
    ///
    /// - Tag: subscribeToViewStateReducers
    private func subscribeToViewStateReducers() {
        //let viewStateSet1 = Publishers.CombineLatest3(
        //    mainScreenViewState.objectWillChange,
        //    self.sendLiveLocationConfirmationDialogViewState.objectWillChange,
        //    self.accessCodeVerificationDialogViewState.objectWillChange
        //)
        //
        //let viewStateSet2 = Publishers.CombineLatest(
        //    self.authScreenViewState.objectWillChange,
        //    self.meScreenViewState.objectWillChange
        //)
        
        if self.reducers.isEmpty { return }
        
        (state as? AnyPublisher<State, Never>)?.sink {[weak self] (_state) in
            self?.objectWillChange.send()
        }
        .store(in: &cancellables)
        
        //Publishers.CombineLatest(
        //    //viewStateSet1, viewStateSet2
        //    ...self.reducers
        //)
        //.sink { [weak self] (_, _) in
        //    self?.objectWillChange.send()
        //}
        //.store(in: &cancellables)
    }
}
