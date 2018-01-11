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
    private (set) var waypoints: [GpxWaypointEntity] = []

    private weak var delegate: MapDisplayDelegate?
    private var fileEntity: GpxFileEntity?
    private var selectedWaypointIndexes = Set<Int>()

    init(delegate: MapDisplayDelegate) {
        self.delegate = delegate
    }

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
            if waypointList.count == 1 {
                self.delegate?.showMapArea(center: waypointList.first!.coordinate, latitudinalMeters: Constants.oneThousandMetres, longitudinalMeters: Constants.oneThousandMetres)
            }
            else if waypointList.count > 1 {
                let bounds = GpxBounds(forCoordinates: waypointList.map({ $0.coordinate }))
                self.delegate?.showMapArea(center: bounds.center, latitudeDelta: bounds.latitudeDelta, longitudeDelta: bounds.longitudeDelta)
            }
        }
    }

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of waypoint if not known")
    }

    private struct Constants {
        static let oneThousandMetres: CLLocationDistance = 1000
    }
}
