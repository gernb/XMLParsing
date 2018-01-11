//
//  GpxRoute+MapKit.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/31/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit

public extension GpxRoute {

    var polyline: GpxPolyline {
        let coordinates = self.points.map { $0.coordinate }
        let polyline = GpxPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.type = .route
        return polyline
    }
}
