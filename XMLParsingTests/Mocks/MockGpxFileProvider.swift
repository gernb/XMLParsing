//
//  MockGpxFileProvider.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/9/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import XCTest
@testable import XMLParsing

class MockGpxFileProvider: GpxFileProviding {

    enum Exception: Error {
        case noFile
    }

    var gpxFile: GpxFile?

    func getGpxFile(completion: @escaping (Result<GpxFile>) -> Void) {
        DispatchQueue.global().async {
            if let file = self.gpxFile {
                completion(.success(file))
            } else {
                completion(.failure(Exception.noFile))
            }
        }
    }
}
