//
//  Binding.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

/// A wrapper class to make a value participate in binding.
public final class Bindable<T>: CustomDebugStringConvertible {
    fileprivate var initialValue: T
    fileprivate weak var binding: Binding<T>?

    /// The bindable value.
    public var value: T {
        get {
            return binding?.getValue() ?? initialValue
        }
        set {
            guard let binding = binding else { initialValue = newValue; return }
            binding.setValue(newValue)
        }
    }

    /// Description to be output when debugging.
    public var debugDescription: String {
        return "\(value)"
    }

    /**
     Create a new `Bindable` with an initial value.

     - parameter initialValue: The initial value of the `Bindable`.
     */
    public init(_ initialValue: T) {
        self.initialValue = initialValue
    }
}

/// A class linking a `Bindable` value with a control.
public final class Binding<T> {
    fileprivate let setValue: (T) -> Void
    fileprivate let getValue: () -> T?
    private weak var bindable: Bindable<T>?

    /**
     Create a new `Binding`.

     - parameter setValue: The function to be invoked when the `Bindable` value changes.
     - parameter getValue: The function to be invoked to get the current value of the bound control.
     */
    public init(setValue: @escaping (T) -> Void, getValue: @escaping () -> T?) {
        self.setValue = setValue
        self.getValue = getValue
    }

    /**
     Link a `Bindable` value with this `Binding` instance.

     - parameter: The `Bindable` object to link with this `Binding` instance.
     */
    public func bind(_ bindable: Bindable<T>) {
        assert(self.bindable == nil, "Binding is already bound")
        assert(bindable.binding == nil, "Bindable value is already bound")
        bindable.binding = self
        self.bindable = bindable
        setValue(bindable.initialValue)
    }

    /// Remove the linkage between this `Binding` instance and the bound value.
    public func unbind() {
        bindable?.binding = nil
        bindable = nil
    }
}
