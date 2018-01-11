//
//  GpxPathProvider.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/10/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

public enum GpxPathType {
    case route
    case trackSegment
}

public protocol GpxPathProvider {

    var points: [GpxWaypoint] { get }
    var pathType: GpxPathType { get }
}

extension GpxRoute: GpxPathProvider {

    public var pathType: GpxPathType {
        return .route
    }
}

extension GpxTrackSegment: GpxPathProvider {

    public var pathType: GpxPathType {
        return .trackSegment
    }
}
