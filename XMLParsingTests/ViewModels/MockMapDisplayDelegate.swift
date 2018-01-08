//
//  MockMapDisplayDelegate.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/7/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreLocation
import XCTest
@testable import XMLParsing

final class MockMapDisplayDelegate: MapDisplayDelegate {
    var exp: XCTestExpectation?

    func showMapArea(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees) {
        XCTAssertTrue(Thread.isMainThread)
        exp?.fulfill()
    }

    func showMapArea(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
        XCTAssertTrue(Thread.isMainThread)
        exp?.fulfill()
    }
}
