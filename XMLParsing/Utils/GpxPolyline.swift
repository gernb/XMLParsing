//
//  GpxPolyline.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/8/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import MapKit

public class GpxPolyline: MKPolyline {

    public enum GpxType {
        case route
        case trackSegment
    }

    public var type: GpxType!
    public var route: GpxRoute?
    public var trackSegment: GpxTrackSegment?
}
