//
//  GpxRouteEntity+Initialisers.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/31/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData

extension GpxRouteEntity {

    convenience init(context: NSManagedObjectContext, route: GpxRoute) {
        self.init(context: context)
        self.name = route.name
        self.routeDescription = route.routeDescription
    }
}
