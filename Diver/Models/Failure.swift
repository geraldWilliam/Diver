//
//  Failure.swift
//  Diver
//
//  Created by Gerald Burke on 7/15/24.
//

import Foundation

/// Define a concrete implementation of LocalizedError so you can publish errors from Observables and bind to them in views. 
/// If you try to use the `Error` or `LocalizedError` protocol for this, when you pass the error to .alert(isPresented:error:actions:)
/// you‘ll get an error that "Type 'any LocalizedError' cannot conform to LocalizedError". This just means that the modifier expects a
/// concrete type rather than the protocol.
///
/// You could take this type a step further by adopting CustomNSError. Implement that protocol‘s `errorUserInfo` property and, in
/// the dictionary you return, provide a value for NSUnderlyingErrorKey. Then your Failure would contain the original Error, not just its
/// `localizedDescription`.
struct Failure: LocalizedError {
    /// The text displayed to the user.
    let message: String
    /// LocalizedError conformance.
    var errorDescription: String? { message }
    /// Convenience initializer to create a localized error with a string you provide.
    init(_ message: String) {
        self.message = message
    }
    /// Initializer to wrap any error in a `Failure`.
    init(_ error: Error) {
        message = error.localizedDescription
    }
}
