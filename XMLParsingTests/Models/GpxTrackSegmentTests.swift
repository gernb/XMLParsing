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

    func testEncoding() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var sut = GpxTrackSegment()
        sut.add(point: GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0))
        sut.add(point: GpxWaypoint(withNodeName: .trackpoint, latitude: 1.1, longitude: 2.1))

        let data = try! encoder.encode(sut)
        let json = String(data: data, encoding: .utf8)

        XCTAssertNotNil(json)
        let jsonString = """
            {
              "points" : [
                {
                  "latitude" : 1,
                  "longitude" : 2,
                  "nodeName" : "trkpt"
                },
                {
                  "latitude" : 1.1000000000000001,
                  "longitude" : 2.1000000000000001,
                  "nodeName" : "trkpt"
                }
              ]
            }
            """
        XCTAssertEqual(json, jsonString)
    }

    func testDecoding() {
        let jsonString = "{ \"points\":[ { \"latitude\":1, \"longitude\":2, \"nodeName\":\"trkpt\" } ] }"
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let sut = try! decoder.decode(GpxTrackSegment.self, from: jsonData)

        XCTAssertEqual(sut.points.count, 1)
    }
}
