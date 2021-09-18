//
//  File.swift
//  
//
//  Created by Ugochukwu Mmirikwe on 2021/09/13.
//

import Foundation

public protocol StoreMiddlewareProtocol: AnyObject {
    /// Executes this middleware. Use `next` to continue the passed-in `action`, but use` store.dispatch` to send a new action to the `store`.
    /// - Parameters:
    ///   - store: Store instance.
    ///   - next: Function to invoke to pass-on the current action to the next middleware.
    ///   - action: The current [StoreAction](StoreAction) dispatched.
    func run<Store: ReduxStoreProtocol, Action: StoreActionProtocol>(
        store: Store,
        next: @escaping (Action) -> Void,
        action: Action
    )
}
