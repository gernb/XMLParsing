//
//  GpxWaypointTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/27/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import XCTest
@testable import XMLParsing

class GpxWaypointTests: XCTestCase {

    func testXmlPropertyAll() {
        let lat = 1.0
        let lon = 2.0
        let altitude = 3.0
        let date = Date()

        let sut = GpxWaypoint(withNodeName: .trackpoint, latitude: lat, longitude: lon, elevation: altitude, timestamp: date,
                              name: "{name}", comment: "{comment}", description: "{description}", symbol: "{symbol}")
        let xml = sut.xml

        XCTAssertEqual(xml.name, "trkpt")
        XCTAssertEqual(xml.attributes!, ["lat": "\(lat)", "lon": "\(lon)"])
        XCTAssertEqual(xml.content, "")
        XCTAssertEqual(xml.nodes.count, 6)
        XCTAssertEqual(xml.nodes[0].name, "ele")
        XCTAssertNil(xml.nodes[0].attributes)
        XCTAssertEqual(xml.nodes[0].nodes.count, 0)
        XCTAssertEqual(xml.nodes[0].content, "\(altitude)")
        XCTAssertEqual(xml.nodes[1].name, "time")
        XCTAssertNil(xml.nodes[1].attributes)
        XCTAssertEqual(xml.nodes[1].nodes.count, 0)
        XCTAssertEqual(xml.nodes[1].content, date.iso8601String)
        XCTAssertEqual(xml.nodes[2].name, "name")
        XCTAssertNil(xml.nodes[2].attributes)
        XCTAssertEqual(xml.nodes[2].nodes.count, 0)
        XCTAssertEqual(xml.nodes[2].content, "{name}")
        XCTAssertEqual(xml.nodes[3].name, "cmt")
        XCTAssertNil(xml.nodes[3].attributes)
        XCTAssertEqual(xml.nodes[3].nodes.count, 0)
        XCTAssertEqual(xml.nodes[3].content, "{comment}")
        XCTAssertEqual(xml.nodes[4].name, "desc")
        XCTAssertNil(xml.nodes[4].attributes)
        XCTAssertEqual(xml.nodes[4].nodes.count, 0)
        XCTAssertEqual(xml.nodes[4].content, "{description}")
        XCTAssertEqual(xml.nodes[5].name, "sym")
        XCTAssertNil(xml.nodes[5].attributes)
        XCTAssertEqual(xml.nodes[5].nodes.count, 0)
        XCTAssertEqual(xml.nodes[5].content, "{symbol}")
    }

    func testXmlPropertyMin() {
        let lat = 1.0
        let lon = 2.0

        let sut = GpxWaypoint(withNodeName: .trackpoint, latitude: lat, longitude: lon)
        let xml = sut.xml

        XCTAssertEqual(xml.name, "trkpt")
        XCTAssertEqual(xml.attributes!, ["lat": "\(lat)", "lon": "\(lon)"])
        XCTAssertEqual(xml.content, "")
        XCTAssertEqual(xml.nodes.count, 0)
    }

    func testDescriptionPropertyAll() {
        let lat = 1.0
        let lon = 2.0
        let altitude = 3.0
        let date = Date()
        let xmlString = """
            <trkpt lat=\"1.0\" lon=\"2.0\">
            \t<ele>3.0</ele>
            \t<time>\(date.iso8601String)</time>
            \t<name><![CDATA[{name}]]></name>
            \t<cmt><![CDATA[{comment}]]></cmt>
            \t<desc><![CDATA[{description}]]></desc>
            \t<sym><![CDATA[{symbol}]]></sym>
            </trkpt>
            """

        let sut = GpxWaypoint(withNodeName: .trackpoint, latitude: lat, longitude: lon, elevation: altitude, timestamp: date,
                              name: "{name}", comment: "{comment}", description: "{description}", symbol: "{symbol}")
        let description = sut.description

        XCTAssertEqual(description, xmlString)
    }

    func testDescriptionPropertyMin() {
        let lat = 1.0
        let lon = 2.0
        let xmlString = "<trkpt lat=\"1.0\" lon=\"2.0\"></trkpt>"

        let sut = GpxWaypoint(withNodeName: .trackpoint, latitude: lat, longitude: lon)
        let description = sut.description

        XCTAssertEqual(description, xmlString)
    }

    func testInitFromXml() {
        let date = Date()
        let xmlString = """
            <trkpt lat=\"1.0\" lon=\"2.0\">
            \t<ele>3.0</ele>
            \t<time>\(date.iso8601String)</time>
            </trkpt>
            """
        let xmlNode = try! XMLReader.read(contentsOf: xmlString).nodes.first!

        let sut = GpxWaypoint(xml: xmlNode)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.nodeName, .trackpoint)
        XCTAssertEqual(sut!.latitude, 1.0)
        XCTAssertEqual(sut!.longitude, 2.0)
        XCTAssertEqual(sut!.elevationInMetres, 3.0)
        XCTAssertTrue(abs(sut!.timestamp!.timeIntervalSince(date)) < 1.0)
    }

    func testInitFromXml2() {
        let date = Date()
        let xmlString = """
            <wpt lat=\"1.0\" lon=\"2.0\">
            \t<ele>3.0</ele>
            \t<time>\(date.iso8601String)</time>
            \t<name><![CDATA[{name}]]></name>
            \t<desc><![CDATA[{description}]]></desc>
            </wpt>
            """
        let xmlNode = try! XMLReader.read(contentsOf: xmlString).nodes.first!

        let sut = GpxWaypoint(xml: xmlNode)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.nodeName, .waypoint)
        XCTAssertEqual(sut!.latitude, 1.0)
        XCTAssertEqual(sut!.longitude, 2.0)
        XCTAssertEqual(sut!.elevationInMetres, 3.0)
        XCTAssertTrue(abs(sut!.timestamp!.timeIntervalSince(date)) < 1.0)
        XCTAssertEqual(sut!.name, "{name}")
        XCTAssertNil(sut!.comment)
        XCTAssertEqual(sut!.pointDescription, "{description}")
        XCTAssertNil(sut!.symbol)
    }

    func testInitFromXml3() {
        let date = ISO8601DateFormatter().date(from: "2014-09-24T14:55:37Z")!
        let xmlString = """
            <trkpt lat=\"1.0\" lon=\"2.0\">
            \t<ele>3.0</ele>
            \t<time>2014-09-24T14:55:37Z</time>
            </trkpt>
            """
        let xmlNode = try! XMLReader.read(contentsOf: xmlString).nodes.first!

        let sut = GpxWaypoint(xml: xmlNode)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.nodeName, .trackpoint)
        XCTAssertEqual(sut!.latitude, 1.0)
        XCTAssertEqual(sut!.longitude, 2.0)
        XCTAssertEqual(sut!.elevationInMetres, 3.0)
        XCTAssertTrue(abs(sut!.timestamp!.timeIntervalSince(date)) < 1.0)
    }

    func testEncoding() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        let now = Date()
        let sut = GpxWaypoint(withNodeName: .waypoint, latitude: 25.123, longitude: -122.321, elevation: 123.321, timestamp: now, name: "Test Waypoint", description: "A test waypoint", symbol: "Test")

        let data = try! encoder.encode(sut)
        let json = String(data: data, encoding: .utf8)

        XCTAssertNotNil(json)
        let jsonString = """
            {
              "symbol" : "Test",
              "longitude" : -122.321,
              "nodeName" : "wpt",
              "elevation" : 123.321,
              "latitude" : 25.123000000000001,
              "description" : "A test waypoint",
              "timestamp" : "\(Formatter.systemIso8601.string(from: now))",
              "name" : "Test Waypoint"
            }
            """
        XCTAssertEqual(json, jsonString)
    }

    func testDecoding() {
        let now = Date()
        let jsonString = """
            {
                "nodeName":"trkpt",
                "latitude":25.123,
                "longitude":-122.321,
                "elevation":123.321,
                "timestamp":"\(Formatter.systemIso8601.string(from: now))",
                "name":"Test Trackpoint",
                "description":"A test trackpoint"
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let sut = try! decoder.decode(GpxWaypoint.self, from: jsonData)

        XCTAssertEqual(sut.nodeName, .trackpoint)
        XCTAssertEqual(sut.latitude, 25.123)
        XCTAssertEqual(sut.longitude, -122.321)
        XCTAssertEqual(sut.elevationInMetres, 123.321)
        XCTAssertTrue(abs(sut.timestamp!.timeIntervalSince(now)) < 1.0)
        XCTAssertEqual(sut.name, "Test Trackpoint")
        XCTAssertEqual(sut.pointDescription, "A test trackpoint")
        XCTAssertNil(sut.comment)
        XCTAssertNil(sut.symbol)
    }
}
