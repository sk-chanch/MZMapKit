//
//  Buildable.swift
//  iPod
//
//  Created by Fernando Moya de Rivas on 09/12/2019.
//  Copyright © 2019 Fernando Moya de Rivas. All rights reserved.
//

import Foundation
import SwiftUI

/// Adds a helper function to mutate a properties and help implement _Builder_ pattern
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
protocol Buildable { }

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Buildable {

    /// Mutates a property of the instance
    ///
    /// - Parameter keyPath:    `WritableKeyPath` to the instance property to be modified
    /// - Parameter value:      value to overwrite the  instance property
    func mutating<T>(keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = value
        return newSelf
    }
    
    // Add a specific method for bindings
    func binding<T>(_ keyPath: WritableKeyPath<Self, Binding<T>>, _ value: T) -> Self {
        let newSelf = self
        newSelf[keyPath: keyPath].wrappedValue = value
        return newSelf
    }
    
    // Add a method for binding to a State property
    func binding<T>(_ keyPath: WritableKeyPath<Self, Binding<T>>, to state: Binding<T>) -> Self {
        var newSelf = self
        newSelf[keyPath: keyPath] = state
        return newSelf
    }

}
