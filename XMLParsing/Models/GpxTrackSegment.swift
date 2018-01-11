//
//  GpxTrackSegment.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

public struct GpxTrackSegment: Codable, CustomStringConvertible {
    private (set) public var points: [GpxWaypoint]

    public var xml: XMLNode {
        let node = XMLNode(name: Constants.nodeName)
        for point in points {
            node.nodes.append(point.xml)
        }
        return node
    }

    public var description: String {
        return xml.description
    }

    public init(points: [GpxWaypoint] = []) {
        for p in points {
            assert(p.nodeName == Constants.pointNodeName, "Unsupported element type: \(p.nodeName)")
        }
        self.points = points
    }

    public init?(xml: XMLNode) {
        guard xml.name == Constants.nodeName else { return nil }

        var points = [GpxWaypoint]()
        for node in xml.nodes {
            if let point = GpxWaypoint(xml: node), point.nodeName == Constants.pointNodeName {
                points.append(point)
            }
            else {
                Logger.info(category: .model, "Skipping node: \(node.name as Any)")
            }
        }

        self.init(points: points)
    }

    @discardableResult
    public mutating func add(point: GpxWaypoint) -> GpxWaypoint {
        assert(point.nodeName == Constants.pointNodeName, "Unsupported element type: \(point.nodeName)")
        points.append(point)
        return point
    }

    private struct Constants {
        static let nodeName = "trkseg"
        static let pointNodeName = GpxWaypoint.WaypointType.trackpoint
    }

}
