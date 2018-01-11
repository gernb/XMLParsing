//
//  GpxBounds.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/31/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreLocation

public struct GpxBounds: Codable, CustomStringConvertible {
    public let minLatitude: CLLocationDegrees
    public let minLongitude: CLLocationDegrees
    public let maxLatitude: CLLocationDegrees
    public let maxLongitude: CLLocationDegrees

    public var description: String {
        return "(\(minLatitude), \(minLongitude)) -> (\(maxLatitude), \(maxLongitude))"
    }

    public var center: CLLocationCoordinate2D {
        let latitude = minLatitude + (latitudeDelta / 2)
        let longitude = minLongitude + (longitudeDelta / 2)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public var latitudeDelta: CLLocationDegrees {
        return maxLatitude - minLatitude
    }

    public var longitudeDelta: CLLocationDegrees {
        return maxLongitude - minLongitude
    }

    public init(minLatitude: CLLocationDegrees, minLongitude: CLLocationDegrees, maxLatitude: CLLocationDegrees, maxLongitude: CLLocationDegrees) {
        self.minLatitude = minLatitude
        self.minLongitude = minLongitude
        self.maxLatitude = maxLatitude
        self.maxLongitude = maxLongitude
    }

    public init(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees) {
        let minLat = center.latitude - (latitudeDelta / 2)
        let maxLat = center.latitude + (latitudeDelta / 2)
        let minLon = center.longitude - (longitudeDelta / 2)
        let maxLon = center.longitude + (longitudeDelta / 2)
        self.init(minLatitude: minLat, minLongitude: minLon, maxLatitude: maxLat, maxLongitude: maxLon)
    }

    public init(forCoordinates coordinates: [CLLocationCoordinate2D]) {
        assert(coordinates.count > 0, "Insufficient number of coordinates supplied")
        var bounds: (minLat: CLLocationDegrees, minLon: CLLocationDegrees, maxLat: CLLocationDegrees, maxLon: CLLocationDegrees) = (90.0, 180.0, -90.0, -180.0)
        for coord in coordinates {
            if coord.latitude < bounds.minLat { bounds.minLat = coord.latitude }
            if coord.latitude > bounds.maxLat { bounds.maxLat = coord.latitude }
            if coord.longitude < bounds.minLon { bounds.minLon = coord.longitude }
            if coord.longitude > bounds.maxLon { bounds.maxLon = coord.longitude }
        }
        self.init(minLatitude: bounds.minLat, minLongitude: bounds.minLon, maxLatitude: bounds.maxLat, maxLongitude: bounds.maxLon)
    }

    public func union(with other: GpxBounds) -> GpxBounds {
        let minLat = min(minLatitude, other.minLatitude)
        let minLon = min(minLongitude, other.minLongitude)
        let maxLat = max(maxLatitude, other.maxLatitude)
        let maxLon = max(maxLongitude, other.maxLongitude)
        return GpxBounds(minLatitude: minLat, minLongitude: minLon, maxLatitude: maxLat, maxLongitude: maxLon)
    }

    private enum CodingKeys: String, CodingKey {
        case minLatitude = "minLat"
        case minLongitude = "minLon"
        case maxLatitude = "maxLat"
        case maxLongitude = "maxLon"
    }
}

extension GpxBounds: Equatable {

    public static func ==(lhs: GpxBounds, rhs: GpxBounds) -> Bool {
        return lhs.minLatitude == rhs.minLatitude &&
            lhs.maxLatitude == rhs.maxLatitude &&
            lhs.minLongitude == rhs.minLongitude &&
            lhs.maxLongitude == rhs.maxLongitude
    }
}
