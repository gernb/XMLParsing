//
//  GpxBounds+MapKit.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/10/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit

public extension GpxBounds {

    public var coordinateRegion: MKCoordinateRegion {
        if latitudeDelta == 0 && longitudeDelta == 0 {
            return MKCoordinateRegionMakeWithDistance(center, Constants.oneThousandMetres, Constants.oneThousandMetres)
        } else {
            let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
            return MKCoordinateRegionMake(center, span)
        }
    }

    private struct Constants {
        static let oneThousandMetres: CLLocationDistance = 1000
    }
}

public extension MKCoordinateRegion {

    public var gpxBounds: GpxBounds {
        assert(span.latitudeDelta > 0 && span.longitudeDelta > 0)
        return GpxBounds(center: center, latitudeDelta: span.latitudeDelta, longitudeDelta: span.longitudeDelta)
    }
}
