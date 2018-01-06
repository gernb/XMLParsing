//
//  GpxTrackTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/27/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import XCTest
@testable import XMLParsing

class GpxTrackTests: XCTestCase {

    func testXmlProperty() {
        let name = "name " + #function
        let desc = "desc " + #function
        let trkseg = GpxTrackSegment()

        let sut = GpxTrack(name: name, description: desc, segments: [trkseg])
        let xml = sut.xml

        XCTAssertEqual(xml.name, "trk")
        XCTAssertNil(xml.attributes)
        XCTAssertEqual(xml.content, "")
        XCTAssertEqual(xml.nodes.count, 3)
        XCTAssertEqual(xml.nodes[0].name, "name")
        XCTAssertNil(xml.nodes[0].attributes)
        XCTAssertEqual(xml.nodes[0].content, name)
        XCTAssertEqual(xml.nodes[0].nodes.count, 0)
        XCTAssertEqual(xml.nodes[1].name, "desc")
        XCTAssertNil(xml.nodes[1].attributes)
        XCTAssertEqual(xml.nodes[1].content, desc)
        XCTAssertEqual(xml.nodes[1].nodes.count, 0)
        XCTAssertEqual(xml.nodes[2].name, "trkseg")
    }

    func testSegmentsProperty() {
        let trkseg1 = GpxTrackSegment()
        let trkseg2 = GpxTrackSegment()

        var sut = GpxTrack(segments: [trkseg1])

        XCTAssertEqual(sut.segments.count, 1)

        sut.add(segment: trkseg2)

        XCTAssertEqual(sut.segments.count, 2)
    }

    func testDescriptionProperty() {
        let xmlString = """
            <trk>
            \t<name><![CDATA[\(#function)]]></name>
            \t<desc><![CDATA[description]]></desc>
            \t<trkseg></trkseg>
            </trk>
            """

        let sut = GpxTrack(name: #function, description: "description", segments: [GpxTrackSegment()])
        let description = sut.description

        XCTAssertEqual(description, xmlString)
    }

    func testInitFromXml() {
        let xmlString = """
            <trk>
            \t<name><![CDATA[\(#function)]]></name>
            \t<desc><![CDATA[description]]></desc>
            \t<trkseg>
            \t\t<trkpt lat="1.0" lon="2.0"></trkpt>
            \t</trkseg>
            </trk>
            """
        let xmlNode = try! XMLReader.read(contentsOf: xmlString).nodes.first!

        let sut = GpxTrack(xml: xmlNode)

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut!.name, #function)
        XCTAssertEqual(sut!.trackDescription, "description")
        XCTAssertEqual(sut!.segments.count, 1)
        XCTAssertEqual(sut!.segments[0].points.count, 1)
    }

    func testEncodingWithoutComputedProperties() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var sut = GpxTrack(name: "Test Track", description: "A test track")
        sut.add(segment: GpxTrackSegment(points: [GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)]))

        let data = try! encoder.encode(sut)
        let json = String(data: data, encoding: .utf8)

        let jsonString = """
            {
              "name" : "Test Track",
              "segments" : [
                {
                  "points" : [
                    {
                      "latitude" : 1,
                      "longitude" : 2,
                      "nodeName" : "trkpt"
                    }
                  ]
                }
              ],
              "description" : "A test track"
            }
            """
        XCTAssertNotNil(json)
        XCTAssertEqual(json, jsonString)
    }

    func testEncodingWithComputedProperties() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var segment = GpxTrackSegment()
        segment.add(point: GpxWaypoint(withNodeName: .trackpoint, latitude: 37.331705, longitude: -122.030237))
        segment.add(point: GpxWaypoint(withNodeName: .trackpoint, latitude: 47.6441676, longitude: -122.1440535))
        let sut = GpxTrack(name: "Test Track", description: "A test track", segments: [segment])
        sut.calculateComputedProperties()

        XCTAssertNotNil(sut.computedProperties.bounds)

        let data = try! encoder.encode(sut)
        let json = String(data: data, encoding: .utf8)

        print(json!)
        let jsonString = """
            {
              "computedProperties" : {
                "bounds" : {
                  "minLon" : -122.1440535,
                  "maxLat" : 47.644167600000003,
                  "maxLon" : -122.030237,
                  "minLat" : 37.331704999999999
                },
                "duration" : 0,
                "distance" : 1145577.7156467838
              },
              "name" : "Test Track",
              "description" : "A test track",
              "segments" : [
                {
                  "points" : [
                    {
                      "latitude" : 37.331704999999999,
                      "longitude" : -122.030237,
                      "nodeName" : "trkpt"
                    },
                    {
                      "latitude" : 47.644167600000003,
                      "longitude" : -122.1440535,
                      "nodeName" : "trkpt"
                    }
                  ]
                }
              ]
            }
            """
        XCTAssertNotNil(json)
        XCTAssertEqual(json, jsonString)
    }

    func testDecodingWithoutComputedProperties() {
        let jsonString = """
            {
              "name" : "Test Track",
              "segments" : [
                {
                  "points" : [
                    {
                      "latitude" : 1,
                      "longitude" : 2,
                      "nodeName" : "trkpt"
                    }
                  ]
                }
              ]
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let sut = try! decoder.decode(GpxTrack.self, from: jsonData)

        XCTAssertEqual(sut.name, "Test Track")
        XCTAssertEqual(sut.segments.count, 1)
        XCTAssertNil(sut.trackDescription)
        XCTAssertNil(sut.computedProperties.bounds)
    }

    func testDecodingWithComputedProperties() {
        let jsonString = """
            {
              "name" : "Test Track",
              "computedProperties" : {
                "bounds" : {
                  "minLat" : 3.0,
                  "minLon" : -1.0,
                  "maxLon" : 1.0,
                  "maxLat" : 4.0
                }
              },
              "segments" : [
                {
                  "points" : [
                    {
                      "latitude" : 1,
                      "longitude" : 2,
                      "nodeName" : "trkpt"
                    }
                  ]
                }
              ]
            }
            """
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let sut = try! decoder.decode(GpxTrack.self, from: jsonData)

        XCTAssertEqual(sut.name, "Test Track")
        XCTAssertEqual(sut.segments.count, 1)
        XCTAssertNil(sut.trackDescription)
        XCTAssertNotNil(sut.computedProperties.bounds)
    }
}
