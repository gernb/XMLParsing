//
//  GpxPathProvider+MapKit.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/10/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit

public extension GpxPathProvider {

    var polyline: GpxPolyline {
        let coordinates = self.points.map { $0.coordinate }
        let polyline = GpxPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.type = self.pathType.gpxType
        return polyline
    }
}

extension GpxPathType {

    var gpxType: GpxPolyline.GpxType {
        switch self {
        case .route: return .route
        case .trackSegment: return .trackSegment
        }
    }
}
