//
//  GpxWaypointEntity+Initialisers.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData

extension GpxWaypointEntity {

    convenience init(context: NSManagedObjectContext, waypoint: GpxWaypoint) {
        self.init(context: context)
        self.latitude = waypoint.latitude
        self.longitude = waypoint.longitude
        self.name = waypoint.name
        self.waypointDescription = waypoint.pointDescription
    }

    convenience init(context: NSManagedObjectContext, latitude: Double, longitude: Double) {
        self.init(context: context)
        self.latitude = latitude
        self.longitude = longitude
    }
}
