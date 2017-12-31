//
//  MKMapType+Description.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit

extension MKMapType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .standard: return NSLocalizedString("Road", comment: "Map type: Road")
        case .satellite: return NSLocalizedString("Satellite", comment: "Map type: Satellite")
        case .hybrid: return NSLocalizedString("Hybrid", comment: "Map type: Hybrid")
        case .satelliteFlyover: return NSLocalizedString("Satellite Flyover", comment: "Map type: Satellite Flyover")
        case .hybridFlyover: return NSLocalizedString("Hybrid Flyover", comment: "Map type: Hybrid Flyover")
        case .mutedStandard: return NSLocalizedString("Muted Road", comment: "Map type: Muted Road")
        }
    }

    public static var all: [MKMapType] {
        return [.standard, .satellite, .hybrid, .satelliteFlyover, .hybridFlyover, .mutedStandard]
    }
}
