//
//  MKMapView+Binding.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/30/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import MapKit
import UIKit

public extension MKMapView {

    private static var handle: UInt8 = 0
    /// The `MapViewBindings` exposed by this control.
    public var mapViewBindings: MapViewBindings {
        if let b = objc_getAssociatedObject(self, &MKMapView.handle) as? MapViewBindings {
            return b
        }
        else {
            let b = MapViewBindings(self)
            objc_setAssociatedObject(self, &MKMapView.handle, b, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return b
        }
    }

    /// A collection of `Binding` instances for `UILabel`.
    public class MapViewBindings: UIView.ViewBindings {
        private unowned let mapView: MKMapView

        /// `Binding` for the `annotations` property.
        private (set) public lazy var annotations: Binding<[MKAnnotation]> =
            Binding<[MKAnnotation]>(setValue: { [unowned self] v in
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(v)
                },
                                    getValue: { [unowned self] in return self.mapView.annotations })

        /// `Binding` for the `overlays` property.
        private (set) public lazy var overlays: Binding<[MKOverlay]> =
            Binding<[MKOverlay]>(setValue: { [unowned self] v in
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlays(v)
                },
                                 getValue: { [unowned self] in return self.mapView.overlays })

        /// `Binding` for the `region` property.
        private (set) public lazy var region: Binding<MKCoordinateRegion> =
            Binding<MKCoordinateRegion>(setValue: { [unowned self] v in self.mapView.setRegion(v, animated: true) },
                                        getValue: { [unowned self] in return self.mapView.region })

        /// One-way `Binding` of an array of `GpxWaypoint` objects to the `annotations` property.
        private (set) public lazy var gpxWaypoints: Binding<[GpxWaypoint]> =
            Binding<[GpxWaypoint]>(setValue: { [unowned self] v in
                self.mapView.removeAnnotations(self.mapView.annotations)
                for wpt in v { self.mapView.addAnnotation(wpt.pointAnnotation) }
                },
                                   getValue: { return [] })

        /// One-way `Binding` of an array of `GpxWaypointEntity` objects to the `annotations` property.
        private (set) public lazy var waypoints: Binding<[GpxWaypointEntity]> =
            Binding<[GpxWaypointEntity]>(setValue: { [unowned self] v in
                self.mapView.removeAnnotations(self.mapView.annotations)
                for wpt in v { self.mapView.addAnnotation(wpt.pointAnnotation) }
                },
                                         getValue: { return [] })

        /// One-way `Binding` of an array of `GpxTrack` objects to the `overlays` property.
        private (set) public lazy var gpxTracks: Binding<[GpxTrack]> =
            Binding<[GpxTrack]>(setValue: { [unowned self] v in
                self.mapView.removeOverlays(self.mapView.overlays)
                for trk in v {
                    for seg in trk.segments { self.mapView.add(seg.polyline) }
                }
                },
                                getValue: { return [] })

        /// One-way `Binding` of an array of `GpxRoute` objects to the `overlays` property.
        private (set) public lazy var gpxRoutes: Binding<[GpxRoute]> =
            Binding<[GpxRoute]>(setValue: { [unowned self] v in
                self.mapView.removeOverlays(self.mapView.overlays)
                for rte in v { self.mapView.add(rte.polyline) }
                },
                                getValue: { return [] })

        public init(_ mapView: MKMapView) {
            self.mapView = mapView
            super.init(mapView)
        }
    }
}
