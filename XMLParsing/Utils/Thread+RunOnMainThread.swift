//
//  Thread+RunOnMainThread.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

extension Thread {
    static func runOnMainThread(_ block: @escaping () -> Void) {
        if isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
