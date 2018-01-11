//
//  WaypointsListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/7/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreLocation
import Foundation

final class WaypointsListViewModel {

    let selectedWaypoints = Bindable<[GpxWaypointEntity]>([])
    let selectionBounds = Bindable<GpxBounds>(Defaults.bounds)
    private (set) var waypoints: [GpxWaypointEntity] = []

    private var fileEntity: GpxFileEntity?
    private var selectedWaypointIndexes = Set<Int>()

    func updateGpxFileEntity(with file: GpxFileEntity) {
        fileEntity = file
        waypoints = file.sortedWaypoints
        selectedWaypoints.value = []
        selectedWaypointIndexes.removeAll()
    }

    func rowProperties(for index: Int) -> (title: String, subtitle: String?, isSelected: Bool) {
        assert(index < waypoints.count && index >= 0)
        let title = waypoints[index].name ?? Defaults.name
        let subtitle = waypoints[index].waypointDescription
        let isSelected = selectedWaypointIndexes.contains(index)
        return (title, subtitle, isSelected)
    }

    func selectWaypoint(at index: Int) {
        assert(index < waypoints.count && index >= 0)
        guard !selectedWaypointIndexes.contains(index) else { return }
        selectedWaypointIndexes.insert(index)
        selectedWaypointsChanged()
    }

    func deselectWaypoint(at index: Int) {
        guard selectedWaypointIndexes.contains(index) else { return }
        selectedWaypointIndexes.remove(index)
        selectedWaypointsChanged()
    }

    private func selectedWaypointsChanged() {
        let waypointList = selectedWaypointIndexes.map { waypoints[$0] }

        Thread.runOnMainThread {
            self.selectedWaypoints.value = waypointList
            if waypointList.count > 0 {
                let bounds = GpxBounds(forCoordinates: waypointList.map({ $0.coordinate }))
                self.selectionBounds.value = bounds
            }
        }
    }

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of waypoint if not known")
        static let bounds: GpxBounds = {
            let center = CLLocationCoordinate2D(latitude: 37.13284, longitude: -95.78558)
            let latitudeDelta: CLLocationDegrees = 42
            let longitudeDelta: CLLocationDegrees = 62
            return GpxBounds(center: center, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }()
    }
}
