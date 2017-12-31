//
//  Lazy.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/30/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

public class Lazy<T> {
    private var t: T?
    public var constructor: (() -> T)!
    public var value: T {
        if t == nil {
            t = constructor()
        }
        return t!
    }

    public init(_ constructor: (() -> T)? = nil) {
        self.constructor = constructor
    }

    public func reset() {
        t = nil
    }
}
