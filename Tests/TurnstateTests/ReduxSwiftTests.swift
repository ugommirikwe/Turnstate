import XCTest
@testable import Turnstate

final class StoreTests: XCTestCase {
    private var store: Store<AppState>!
    private var unSubscribeFromStore: (() -> Void)!
    private var appStateSubscription: AppState!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        store = Store(
            initialState: .generateAppStateDummy(),
            reducer: AppState.rootReducer,
            middleware: [LoggerMiddleware()]
        )
        
        unSubscribeFromStore = store.subscribe([UUID(): { [weak self] newState in
            self?.appStateSubscription = newState
        }])
    }
    
    override func tearDownWithError() throws {
        unSubscribeFromStore()
        store = nil
        
        try super.tearDownWithError()
    }
    
    func testThatStoreActionCreatesNewStateWithPayload() throws {
        XCTAssertEqual(store.getState().user.name, "Ugo M")
        XCTAssertEqual(appStateSubscription.user.name, "Ugo M")
        
        // Arrange
        let user = User(id: "id", username: "Mel", name: "Melissa")
        
        // Act
        store.dispatch(StoreAction.UserModified(user))
        
        // Assert
        XCTAssertEqual(store.getState().user.name, "Melissa")
        XCTAssertEqual(appStateSubscription.user.name, "Melissa")
        
        var anotherUser = user
        anotherUser.username = "kingsley"
        anotherUser.name = "Kingsley"
        store.dispatch(StoreAction.UserModified(anotherUser))
        
        XCTAssertEqual(store.getState().user.name, "Kingsley")
        XCTAssertEqual(appStateSubscription.user.name, "Kingsley")
    }
    
    func testAddingTodo() throws {
        XCTAssertTrue(appStateSubscription.todos.isEmpty)
        
        let todo = Todo(
            title: "My Todo",
            user: User(id: "jjj", username: "ugo", name: "Ugo")
        )
        
        store.dispatch(StoreAction.TodoAddRequested(todo))
        
        XCTAssertEqual(appStateSubscription.todos, [todo])
    }
}


struct AppState: StoreStateProtocol {
    private(set) var user: User
    private(set) var todos: [Todo] = []
    
    static let rootReducer: Reducer = combineReducers(
        userReducer,
        todoReducer
    )

    static func generateAppStateDummy() -> AppState {
        return AppState(user: .generateUserDummy(), todos: [])
    }
}

let userReducer: Reducer<AppState> = { state, action in
    switch action as! StoreAction {
        
    case .UserModified(let user):
        return state.copy(updating: \AppState.user, to: user)
        
    case .UserAddRequested(_): fallthrough
        
    default: break
    }
    
    return state
}

let todoReducer: Reducer<AppState> = { state, action in
    switch action as! StoreAction {
        
    case .TodoAddRequested(let todo):
        return state.copy(updating: \AppState.todos, to: state.todos + [todo])
        
    default: break
    }
    
    return state
}

struct User: Equatable {
    let id: String
    var username: String
    var name: String

    
    static func generateUserDummy() -> User {
        return User(id: "test", username: "ugo", name: "Ugo M")
    }
}

struct Todo: Equatable {
    let id: String = UUID().uuidString
    var title: String
    var completed: Bool = false
    var user: User

}

enum StoreAction: StoreActionProtocol {
    case UserModified(User)
    case UserAddRequested(User)
    
    case TodoAddRequested(Todo)
}

class LoggerMiddleware: StoreMiddlewareProtocol {
    func run(
        store: StoreAPI,
        next: @escaping (StoreActionProtocol) -> Void,
        action: StoreActionProtocol
    ) {
        dump(store.getState(), name: "Old AppState")
        next(action)
        dump(store.getState(), name: "New AppState")
    }
}
