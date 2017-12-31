//
//  TestUtils.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation
import XCTest

final class TestUtils {

    static func cleanDirectory(_ url: URL) {
        let fm = FileManager.default
        do {
            for file in try fm.contentsOfDirectory(atPath: url.path) {
                try fm.removeItem(at: url.appendingPathComponent(file))
            }
        }
        catch let error {
            XCTFail("Failed to clean the test directory: \(error)")
        }
    }
}
