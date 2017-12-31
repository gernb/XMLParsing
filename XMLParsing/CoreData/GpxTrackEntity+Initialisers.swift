//
//  GpxTrackEntity+Initialisers.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData

extension GpxTrackEntity {

    convenience init(context: NSManagedObjectContext, track: GpxTrack) {
        self.init(context: context)
        self.name = track.name
        self.trackDescription = track.trackDescription
    }
}
