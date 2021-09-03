import Combine

/// - Tag: ReduxStoreProtocol
public protocol ReduxStoreProtocol: AnyObject {
    associatedtype State
    associatedtype StoreAction: RawRepresentable
    associatedtype StoreMiddleware: StoreMiddlewareProtocol
    
    var middlewares: [StoreMiddleware] { get }
    var storeActionDispatched: StoreAction? { get set }
    
    func getState() -> State
    func dispatch(action: StoreAction) -> Void
}

extension ReduxStoreProtocol {
    public func dispatch(action: StoreAction) -> Void {
        if self.middlewares.isEmpty {
            self.storeActionDispatched = action
            return
        }

        var currentIndex = middlewares.startIndex
        let endIndex = middlewares.endIndex - 1

        var middlewarePluginsCalled: [String] = []

        func run<StoreAction>(_ middleware: StoreMiddleware, _ action: StoreAction, _ index: Int) {
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
                        self.storeActionDispatched = (action as! Self.StoreAction)
                        return
                    }
                    run(self.middlewares[currentIndex], ac, currentIndex)
                },
                action: action
            )
        }
        
        run(middlewares.first!, action, 0)
    }
}
