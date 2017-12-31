//
//  MKCoordinateRegion+MapRect.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/30/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {

    var mapRect: MKMapRect {
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            self.center.latitude + self.span.latitudeDelta / 2,
            self.center.longitude - self.span.longitudeDelta / 2))

        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
            self.center.latitude - self.span.latitudeDelta / 2,
            self.center.longitude + self.span.longitudeDelta / 2))

        return MKMapRectMake(min(a.x, b.x), min(a.y, b.y), abs(a.x - b.x), abs(a.y - b.y))
    }
}
