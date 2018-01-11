//
//  GpxFile.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

public struct GpxFile: Codable, CustomStringConvertible {
    private (set) public var routes: [GpxRoute]
    private (set) public var tracks: [GpxTrack]
    private (set) public var waypoints: [GpxWaypoint]

    public var xml: XMLNode {
        let attributes = [Constants.version.key: Constants.version.value,
                          Constants.creator.key: Constants.creator.value,
                          Constants.xmlns.key: Constants.xmlns.value]
        let node = XMLNode(name: Constants.nodeName, attributes: attributes)
        for wpt in waypoints {
            node.nodes.append(wpt.xml)
        }
        for rte in routes {
            node.nodes.append(rte.xml)
        }
        for t in tracks {
            node.nodes.append(t.xml)
        }
        return node
    }

    public var description: String {
        return xml.description
    }

    public static func read(fromUrl url: URL, completion: @escaping (Result<GpxFile>) -> Void) {
        DispatchQueue.global().async {
            do {
                let xml = try XMLReader.read(contentsOf: url)
                guard let gpxNode = xml.nodes.first else {
                    completion(.failure(Exception.noGpxNodeFound))
                    return
                }
                guard let gpxFile = GpxFile(xml: gpxNode) else {
                    completion(.failure(Exception.noGpxNodeFound))
                    return
                }
                completion(.success(gpxFile))
            }
            catch let error {
                completion(.failure(error))
            }
        }
    }

    public init(waypoints: [GpxWaypoint] = [], routes: [GpxRoute] = [], tracks: [GpxTrack] = []) {
        for wpt in waypoints {
            assert(wpt.nodeName == Constants.pointNodeName, "Unsupported element type: \(wpt.nodeName)")
        }
        self.waypoints = waypoints
        self.routes = routes
        self.tracks = tracks
    }

    public init?(xml: XMLNode) {
        guard xml.name == Constants.nodeName else { return nil }

        var waypoints = [GpxWaypoint]()
        var routes = [GpxRoute]()
        var tracks = [GpxTrack]()
        for node in xml.nodes {
            if let wpt = GpxWaypoint(xml: node), wpt.nodeName == Constants.pointNodeName {
                waypoints.append(wpt)
            }
            else if let rte = GpxRoute(xml: node) {
                routes.append(rte)
            }
            else if let t = GpxTrack(xml: node) {
                tracks.append(t)
            }
            else {
                Logger.info(category: .model, "Skipping node: \(node.name as Any)")
            }
        }

        self.init(waypoints: waypoints, routes: routes, tracks: tracks)
    }

    @discardableResult
    public mutating func add(waypoint: GpxWaypoint) -> GpxWaypoint {
        assert(waypoint.nodeName == Constants.pointNodeName, "Unsupported element type: \(waypoint.nodeName)")
        waypoints.append(waypoint)
        return waypoint
    }

    @discardableResult
    public mutating func add(route: GpxRoute) -> GpxRoute {
        routes.append(route)
        return route
    }

    @discardableResult
    public mutating func add(track: GpxTrack) -> GpxTrack {
        tracks.append(track)
        return track
    }

    enum Exception: Error {
        case noGpxNodeFound
    }

    private struct Constants {
        static let nodeName = "gpx"
        static let pointNodeName = GpxWaypoint.WaypointType.waypoint
        struct version {
            static let key = "version"
            static let value = "1.1"
        }
        struct creator {
            static let key = "creator"
            static let value = "Hike &amp; Bike for iOS http://1dot0.net"
        }
        struct xmlns {
            static let key = "xmlns"
            static let value = "http://www.topografix.com/GPX/1/1"
        }
    }
}
