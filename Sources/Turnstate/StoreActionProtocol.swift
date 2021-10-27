//
//  Copyright (c) 2021. Ugo Mmirikwe
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// Defines a base type for actions that can be dispatched in an instance of a [store](x-source-tag://Store). An action represents an object describing a change, alongside any associated piece of data (usually referred to as its payload), that makes sense for your application. Actions are the only way to get data into the store, so any data, whether from UI events, network callbacks, or other sources such as WebSockets needs to eventually be dispatched as actions.
///
/// Apps must create an `enum` that extends this protocol and then define cases inside of the enum that represents the actions that can be dispatched to the [store](x-source-tag://Store).
///
/// For example:
///
/// ```
/// enum Action: StoreActionProtocol {
///     case UserCreateRequested(User)
/// }
/// ```
///
/// where `UserCreateRequested` is the type of the action to be dispatched for creating a `User` object that is passed as a payload.
///
/// - Tag: StoreActionProtocol
public protocol StoreActionProtocol {}
