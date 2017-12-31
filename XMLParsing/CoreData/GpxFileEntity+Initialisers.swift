//
//  GpxFileEntity+Initialisers.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/30/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData

extension GpxFileEntity {

    convenience init(context: NSManagedObjectContext, name: String, filename: String) {
        self.init(context: context)
        self.name = name
        self.path = filename
        self.fileParsed = false
    }

    func parse(file: GpxFile) {
        guard !fileParsed else {
            Logger.error(category: .model, "Already parsed a file")
            return
        }
        guard let moc = managedObjectContext else {
            Logger.error(category: .model, "No ManagedObjectContext defined")
            return
        }

        var sequenceNumber: Int32 = 1
        for track in file.tracks {
            let trackEntity = GpxTrackEntity(context: moc, track: track)
            trackEntity.file = self
            trackEntity.sequenceNumber = sequenceNumber
            sequenceNumber += 1
        }

        sequenceNumber = 1
        for route in file.routes {
            let rteEntity = GpxRouteEntity(context: moc, route: route)
            rteEntity.file = self
            rteEntity.sequenceNumber = sequenceNumber
            sequenceNumber += 1
        }

        sequenceNumber = 1
        for waypoint in file.waypoints {
            let wptEntity = GpxWaypointEntity(context: moc, waypoint: waypoint)
            wptEntity.file = self
            wptEntity.sequenceNumber = sequenceNumber
            sequenceNumber += 1
        }

        fileParsed = true
    }
}
