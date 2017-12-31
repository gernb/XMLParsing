//
//  Result.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public typealias VoidResult = Result<Void>

public extension Result where T == Void {

    public static var success: Result {
        return .success(())
    }
}
