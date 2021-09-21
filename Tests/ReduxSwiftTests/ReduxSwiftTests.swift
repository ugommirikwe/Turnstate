    import XCTest
    @testable import ReduxSwift

    final class ReduxStoreTests: XCTestCase {
        private var reduxStore: ReduxStore<AppState>!
        private var unSubscribeFromStore: (() -> Void)!
        private var appStateSubscription: AppState!
        
        override func setUpWithError() throws {
            reduxStore = ReduxStore(
                initialState: AppState(),
                reducers: [AppState.userStateReducer],
                middleware: [SomeMiddleware()]
            )
            
            unSubscribeFromStore = reduxStore.subscribe([UUID(): { [weak self] newState in
                self?.appStateSubscription = newState
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
            reduxStore.dispatch(StoreAction.UserModified(user))
            
            // Assert
            XCTAssertEqual(reduxStore.getState().user.name, "Melissa")
            XCTAssertEqual(appStateSubscription.user.name, "Melissa")
            
            var anotherUser = user
            anotherUser.username = "kingsley"
            anotherUser.name = "Kingsley"
            reduxStore.dispatch(StoreAction.UserModified(anotherUser))

            XCTAssertEqual(reduxStore.getState().user.name, "Kingsley")
            XCTAssertEqual(appStateSubscription.user.name, "Kingsley")
        }
    }

    
    struct AppState: Equatable, Codable {
        var user: User = User(id: "test", username: "ugo", name: "Ugo M")
        
        static func userStateReducer(
            state: AppState = .init(),
            action: StoreActionProtocol
        ) -> AppState {
            if case .UserModified(let usr) = action as! StoreAction {
                return AppState(user: usr)
            }
            
            return state
        }
    }
    
    struct User: Equatable, Codable {
        let id: String
        var username: String
        var name: String
    }
    
    enum StoreAction: StoreActionProtocol {
        case UserModified(User)
    }
    
    class SomeMiddleware: StoreMiddlewareProtocol {
        func run(
            store: StoreAPI,
            next: @escaping (StoreActionProtocol) -> Void,
            action: StoreActionProtocol
        ) {
            switch action as! StoreAction {
            case .UserModified(_):
                break
            }
        
        dump(store.getState(), name: "Old AppState")
        next(action)
        dump(store.getState(), name: "New AppState")
        }
    }
