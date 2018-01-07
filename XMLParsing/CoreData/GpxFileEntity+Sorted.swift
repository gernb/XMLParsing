//
//  GpxFileEntity+Sorted.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/7/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

extension GpxFileEntity {

    var sortedTracks: [GpxTrackEntity] {
        return (tracks!.allObjects as! [GpxTrackEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }

    var sortedRoutes: [GpxRouteEntity] {
        return (routes!.allObjects as! [GpxRouteEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }

    var sortedWaypoints: [GpxWaypointEntity] {
        return (waypoints!.allObjects as! [GpxWaypointEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }
}
