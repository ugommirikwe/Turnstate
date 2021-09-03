//
//  File.swift
//  
//
//  Created by Ugochukwu Mmirikwe on 2021/08/18.
//

import Foundation

public protocol StoreMiddlewareProtocol {
    /// Executes this middleware. Use `next` to continue the passed-in `action`, but use` store.dispatch` to send a new action to the `store`.
    /// - Parameters:
    ///   - store: Store instance.
    ///   - next: Function to invoke to pass-on the current action to the next middleware.
    ///   - action: The current [StoreAction](StoreAction) dispatched.
    func run<Store>(
        store: Store,
        next: @escaping (StoreAction) -> Void,
        action: StoreAction
    )
}
