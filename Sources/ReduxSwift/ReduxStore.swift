import Foundation

/// Concrete implementation of this library's Redux-like Store.
final public class ReduxStore<State: Equatable, StoreAction: StoreActionProtocol>: ReduxStoreProtocol {
    public typealias Reducer = (State, StoreAction) -> State
    public typealias Subscriber = [UUID: (State) -> Void]
    
    private var state: State
    private let reducers: [Reducer]
    private let middleware: [StoreMiddlewareProtocol]
    private var storeSubscribers: Subscriber = [:]
    
    public init(
        initialState: State,
        reducers: [Reducer],
        middleware: [StoreMiddlewareProtocol] = []
    ) {
        self.state = initialState
        self.reducers = reducers
        self.middleware = middleware
    }
    
    final public func getState() -> State {
        return self.state
    }
    
    final public func dispatch(action: StoreAction) {
        if middleware.isEmpty {
            invokeReducers(with: action)
            return
        }

        var currentIndex = middleware.startIndex
        let endIndex = middleware.endIndex - 1
        var middlewarePluginsCalled: [String] = []

        func run(_ mware: StoreMiddlewareProtocol, _ action: StoreAction, _ index: Int) {
            mware.run(
                store: self,
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
                    
                    run(self.middleware[currentIndex], ac as! StoreAction , currentIndex)
                },
                action: action
            )
        }
        
        run(middleware.first!, action, 0)
    }
    
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
