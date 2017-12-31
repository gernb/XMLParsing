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

}
