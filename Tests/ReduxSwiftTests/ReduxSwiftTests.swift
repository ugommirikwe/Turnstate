    import XCTest
    @testable import ReduxSwift

    final class ReduxStoreTests: XCTestCase {
        private var reduxStore: ReduxStore<AppState, StoreAction>!
        private var unSubscribeFromStore: (() -> Void)!
        private var appStateSubscription: AppState!
        
        override func setUpWithError() throws {
            reduxStore = ReduxStore(
                initialState: AppState(),
                reducers: [AppState.userStateReducer],
                middleware: [SomeMiddleware()]
            )
            
            appStateSubscription = reduxStore.getState()
            
            unSubscribeFromStore = reduxStore.subscribe([UUID(): { [self] newState in
                appStateSubscription = newState
            }])
        }
        
        override func tearDownWithError() throws {
            unSubscribeFromStore()
            reduxStore = nil
        }
        
        func testThatStoreActionCreatesNewStateWithPayload() {
            XCTAssertEqual(reduxStore.getState().user.name, "Ugo M")
            XCTAssertEqual(appStateSubscription.user.name, "Ugo M")
            
            // Arrange
            let user = User(id: "id", username: "Mel", name: "Melissa")
            
            // Act
            reduxStore.dispatch(action: .UserModified(user))
            
            // Assert
            XCTAssertEqual(reduxStore.getState().user.name, "Melissa")
            XCTAssertEqual(appStateSubscription.user.name, "Melissa")
            
            let anotherUser = User(id: "id", username: "kingsley", name: "Kingsley")
            reduxStore.dispatch(action: .UserModified(anotherUser))

            XCTAssertEqual(reduxStore.getState().user.name, "Kingsley")
            XCTAssertEqual(appStateSubscription.user.name, "Kingsley")
        }
    }

    
    struct AppState: Equatable, Codable {
        var user: User = User(id: "test", username: "ugo", name: "Ugo M")
        
        static func userStateReducer(
            state: AppState = .init(),
            action: StoreAction
        ) -> AppState {
            if case .UserModified(let usr) = action {
                return AppState(user: usr)
            }
            
            return state
        }
    }
    
    struct User: Equatable, Codable {
        let id: String
        let username: String
        let name: String
    }
    
    enum StoreAction {
        case UserModified(User)
    }
    
    class SomeMiddleware: StoreMiddlewareProtocol {
        func run<Store: ReduxStoreProtocol, StoreAction>(
            store: Store,
            next: @escaping (StoreAction) -> Void,
            action: StoreAction
        ) {
            dump(store.getState(), name: "Old AppState")
            next(action)
            dump(store.getState(), name: "New AppState")
        }
    }
