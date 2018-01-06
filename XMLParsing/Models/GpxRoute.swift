//
//  GpxRoute.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/31/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreLocation

public struct GpxRoute: Codable, CustomStringConvertible {
    public var name: String?
    public var routeDescription: String?
    private (set) var points: [GpxWaypoint]

    public class ComputedProperties: Codable {
        fileprivate (set) public var bounds: GpxBounds?
        fileprivate (set) public var duration: TimeInterval?
        fileprivate (set) public var distance: CLLocationDistance?
    }
    private (set) public var computedProperties = ComputedProperties()

    public var xml: XMLNode {
        let node = XMLNode(name: Constants.nodeName)
        if let name = name {
            node.nodes.append(XMLNode(name: Constants.name, content: name, escapeContent: true))
        }
        if let desc = routeDescription {
            node.nodes.append(XMLNode(name: Constants.description, content: desc, escapeContent: true))
        }
        for point in points {
            node.nodes.append(point.xml)
        }
        return node
    }

    public var description: String {
        return xml.description
    }

    public init(name: String? = nil, description: String? = nil, points: [GpxWaypoint] = []) {
        for p in points {
            assert(p.nodeName == Constants.pointNodeName, "Unsupported element type: \(p.nodeName)")
        }
        self.name = name
        self.routeDescription = description
        self.points = points
    }

    public init?(xml: XMLNode) {
        guard xml.name == Constants.nodeName else { return nil }

        var name: String?
        if let nameNode = xml.childNode(named: Constants.name) {
            name = nameNode.content
        }

        var desc: String?
        if let descNode = xml.childNode(named: Constants.description) {
            desc = descNode.content
        }

        var points = [GpxWaypoint]()
        for node in xml.nodes {
            if let point = GpxWaypoint(xml: node), point.nodeName == Constants.pointNodeName {
                points.append(point)
            }
            else {
                if (node.name != Constants.name) && (node.name != Constants.description) {
                    Logger.info(category: .model, "Skipping node: \(node.name as Any)")
                }
            }
        }

        self.init(name: name, description: desc, points: points)
    }

    @discardableResult
    public mutating func add(point: GpxWaypoint) -> GpxWaypoint {
        assert(point.nodeName == Constants.pointNodeName, "Unsupported element type: \(point.nodeName)")
        points.append(point)
        computedProperties = ComputedProperties()
        return point
    }

    public func calculateComputedProperties() {
        var bounds: (minLat: CLLocationDegrees, minLon: CLLocationDegrees, maxLat: CLLocationDegrees, maxLon: CLLocationDegrees) = (90.0, 180.0, -90.0, -180.0)
        var duration: TimeInterval = 0
        var distance: CLLocationDistance = 0

        var previousTimestamp: Date? = nil
        var previousLocation: CLLocation? = nil
        for pt in points {
            if pt.latitude < bounds.minLat { bounds.minLat = pt.latitude }
            if pt.latitude > bounds.maxLat { bounds.maxLat = pt.latitude }
            if pt.longitude < bounds.minLon { bounds.minLon = pt.longitude }
            if pt.longitude > bounds.maxLon { bounds.maxLon = pt.longitude }

            if let prev = previousTimestamp, let current = pt.timestamp {
                let delta = current.timeIntervalSince(prev)
                duration += delta
            }
            previousTimestamp = pt.timestamp

            if let prev = previousLocation {
                let delta = prev.distance(from: pt.location)
                distance += delta
            }
            previousLocation = pt.location
        }

        computedProperties.bounds = GpxBounds(minLatitude: bounds.minLat, minLongitude: bounds.minLon, maxLatitude: bounds.maxLat, maxLongitude: bounds.maxLon)
        computedProperties.duration = duration
        computedProperties.distance = distance
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case routeDescription = "description"
        case points
        case computedProperties
    }

    private struct Constants {
        static let nodeName = "rte"
        static let name = "name"
        static let description = "desc"
        static let pointNodeName = GpxWaypoint.WaypointType.routepoint
    }

}

extension GpxRoute {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(routeDescription, forKey: .routeDescription)
        if computedProperties.bounds != nil {
            try container.encode(computedProperties, forKey: .computedProperties)
        }
        try container.encode(points, forKey: .points)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let description = try container.decodeIfPresent(String.self, forKey: .routeDescription)
        let computedProperties = try container.decodeIfPresent(ComputedProperties.self, forKey: .computedProperties)
        let points = try container.decodeIfPresent([GpxWaypoint].self, forKey: .points)

        self.init(name: name, description: description, points: points ?? [])
        if let computedProperties = computedProperties {
            self.computedProperties = computedProperties
        }
    }
}
