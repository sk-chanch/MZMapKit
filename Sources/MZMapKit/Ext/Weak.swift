//
//  Weak.swift
//  JERTAM
//
//  Created by Chanchana on 18/7/2567 BE.
//

import Foundation

//https://github.com/siteline/swiftui-introspect?tab=readme-ov-file#keep-instances-outside-the-customize-closure
@propertyWrapper
final class Weak<T: AnyObject> {
    private weak var _wrappedValue: T?

    public var wrappedValue: T? {
        get { _wrappedValue }
        set { _wrappedValue = newValue }
    }

    public init(wrappedValue: T? = nil) {
        self._wrappedValue = wrappedValue
    }
}

