//
//  GpxTrackSegment+MapKit.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit

public extension GpxTrackSegment {
    var polyline: MKPolyline {
        let coordinates = self.points.map { $0.coordinate }
        let polyline = GpxPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.type = .trackSegment
        polyline.trackSegment = self
        return polyline
    }
}
