//
//  GpxWaypoint+MapKit.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/30/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit

extension GpxWaypoint {

    var pointAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        return annotation
    }
}
