//
//  GpxWaypoint+CoreLocation.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreLocation

public extension GpxWaypoint {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    var location: CLLocation {
        return CLLocation(coordinate: self.coordinate, altitude: self.elevationInMetres ?? 0.0, horizontalAccuracy: 0.0, verticalAccuracy: 0.0, timestamp: self.timestamp ?? Date())
    }

    init(coordinate: CLLocationCoordinate2D, type: WaypointType) {
        self.init(withNodeName: type, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    init(location: CLLocation, type: WaypointType) {
        self.init(withNodeName: type, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, elevation: location.altitude, timestamp: location.timestamp)
    }
}
