//
//  GpxRoute.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/31/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreLocation

public struct GpxRoute: CustomStringConvertible {

    public typealias BoundsType = (minLat: CLLocationDegrees, minLon: CLLocationDegrees, maxLat: CLLocationDegrees, maxLon: CLLocationDegrees)

    public var name: String?
    public var routeDescription: String?
    private (set) var points: [GpxWaypoint]

    public class ComputedProperties {
        fileprivate (set) public var bounds: BoundsType?
        fileprivate (set) public var center: CLLocationCoordinate2D?
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
        var bounds: BoundsType = (90.0, 180.0, -90.0, -180.0)
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

        computedProperties.bounds = bounds
        computedProperties.duration = duration
        computedProperties.distance = distance
        computedProperties.center = calculateCenter()
    }

    private func calculateCenter() -> CLLocationCoordinate2D {
        guard let bounds = computedProperties.bounds else {
            fatalError("Bounds have not been calculated yet")
        }
        let latitude = bounds.minLat + ((bounds.maxLat - bounds.minLat) / 2)
        let longitude = bounds.minLon + ((bounds.maxLon - bounds.minLon) / 2)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private struct Constants {
        static let nodeName = "rte"
        static let name = "name"
        static let description = "desc"
        static let pointNodeName = GpxWaypoint.WaypointType.routepoint
    }

}
