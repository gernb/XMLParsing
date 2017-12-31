//
//  GpxWaypoint.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

public struct GpxWaypoint: CustomStringConvertible {
    public enum WaypointType: String {
        case waypoint = "wpt"
        case trackpoint = "trkpt"
        case routepoint = "rtept"
    }

    public let nodeName: WaypointType
    public let latitude: Double
    public let longitude: Double
    public let elevationInMetres: Double?
    public let timestamp: Date?
    public let name: String?
    public let comment: String?
    public let pointDescription: String?
    public let symbol: String?

    public var xml: XMLNode {
        let attributes = [Constants.latitude: "\(latitude)",
            Constants.longitude: "\(longitude)"]
        let node = XMLNode(name: nodeName.rawValue, attributes: attributes)
        if let elevation = elevationInMetres {
            let elevationNode = XMLNode(name: Constants.elevation, content: "\(elevation)")
            node.nodes.append(elevationNode)
        }
        if let timestamp = timestamp {
            let timeNode = XMLNode(name: Constants.time, content: timestamp.iso8601String)
            node.nodes.append(timeNode)
        }
        if let name = name {
            let nameNode = XMLNode(name: Constants.name, content: name, escapeContent: true)
            node.nodes.append(nameNode)
        }
        if let comment = comment {
            let cmtNode = XMLNode(name: Constants.comment, content: comment, escapeContent: true)
            node.nodes.append(cmtNode)
        }
        if let description = pointDescription {
            let descNode = XMLNode(name: Constants.description, content: description, escapeContent: true)
            node.nodes.append(descNode)
        }
        if let symbol = symbol {
            let symNode = XMLNode(name: Constants.symbol, content: symbol, escapeContent: true)
            node.nodes.append(symNode)
        }
        return node
    }

    public var description: String {
        return xml.description
    }

    public init(withNodeName nodeName: WaypointType,
                latitude: Double,
                longitude: Double,
                elevation: Double? = nil,
                timestamp: Date? = nil,
                name: String? = nil,
                comment: String? = nil,
                description: String? = nil,
                symbol: String? = nil) {

        self.nodeName = nodeName
        self.latitude = latitude
        self.longitude = longitude
        self.elevationInMetres = elevation
        self.timestamp = timestamp
        self.name = name
        self.comment = comment
        self.pointDescription = description
        self.symbol = symbol
    }

    public init?(xml: XMLNode) {
        guard let xmlName = xml.name, let nodeName = WaypointType(rawValue: xmlName) else { return nil }

        guard let latString = xml.attributes?[Constants.latitude],
            let lonString = xml.attributes?[Constants.longitude]
            else { return nil }
        guard let lat = Double(latString), let lon = Double(lonString) else { return nil }

        var elevation: Double?
        if let eleNode = xml.childNode(named: Constants.elevation) {
            elevation = Double(eleNode.content)
        }

        var timestamp: Date?
        if let timeNode = xml.childNode(named: Constants.time) {
            timestamp = timeNode.content.dateFromISO8601 ?? Formatter.systemIso8601.date(from: timeNode.content)
            if timestamp == nil {
                Logger.warning(category: .model, "Unable to parse timestamp: \(timeNode.content)")
            }
        }

        var name: String?
        if let node = xml.childNode(named: Constants.name) {
            name = node.content
        }

        var comment: String?
        if let node = xml.childNode(named: Constants.comment) {
            comment = node.content
        }

        var description: String?
        if let node = xml.childNode(named: Constants.description) {
            description = node.content
        }

        var symbol: String?
        if let node = xml.childNode(named: Constants.symbol) {
            symbol = node.content
        }

        self.init(withNodeName: nodeName,
                  latitude: lat,
                  longitude: lon,
                  elevation: elevation,
                  timestamp: timestamp,
                  name: name,
                  comment: comment,
                  description: description,
                  symbol: symbol)
    }

    private struct Constants {
        static let latitude = "lat"
        static let longitude = "lon"
        static let elevation = "ele"
        static let time = "time"
        static let name = "name"
        static let comment = "cmt"
        static let description = "desc"
        static let symbol = "sym"
    }
}

