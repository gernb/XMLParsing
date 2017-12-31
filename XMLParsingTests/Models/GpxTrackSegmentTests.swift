//
//  GpxTrackSegmentTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/27/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import XCTest
@testable import XMLParsing

class GpxTrackSegmentTests: XCTestCase {

    func testXmlProperty() {
        let trkpt = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)

        let sut = GpxTrackSegment(points: [trkpt])
        let xml = sut.xml

        XCTAssertEqual(xml.name, "trkseg")
        XCTAssertNil(xml.attributes)
        XCTAssertEqual(xml.content, "")
        XCTAssertEqual(xml.nodes.count, 1)
        XCTAssertEqual(xml.nodes[0].name, "trkpt")
    }

    func testPointsProperty() {
        let trkpt1 = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)
        let trkpt2 = GpxWaypoint(withNodeName: .trackpoint, latitude: 3.0, longitude: 4.0)

        var sut = GpxTrackSegment(points: [trkpt1])

        XCTAssertEqual(sut.points.count, 1)

        sut.add(point: trkpt2)

        XCTAssertEqual(sut.points.count, 2)
    }

    func testDescriptionProperty() {
        let xmlString = """
            <trkseg>
            \t<trkpt lat=\"1.0\" lon=\"2.0\"></trkpt>
            </trkseg>
            """

        let sut = GpxTrackSegment(points: [GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)])
        let description = sut.description

        XCTAssertEqual(description, xmlString)
    }

    func testInitFromXml() {
        let xmlString = """
            <trkseg>
            \t<trkpt lat=\"1.0\" lon=\"2.0\"></trkpt>
            \t<trkpt lat=\"1.1\" lon=\"2.1\"></trkpt>
            </trkseg>
            """
        let xmlNode = try! XMLReader.read(contentsOf: xmlString).nodes.first!

        let sut = GpxTrackSegment(xml: xmlNode)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.points.count, 2)
    }

}
