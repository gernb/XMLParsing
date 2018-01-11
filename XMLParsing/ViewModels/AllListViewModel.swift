//
//  AllListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/10/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreLocation
import Foundation

final class AllListViewModel {

    enum Section: Int {
        case tracks = 0
        case routes = 1
        case waypoints = 2

        static var all: [Section] = [.tracks, .routes, .waypoints]

        var title: String {
            switch self {
            case .tracks: return NSLocalizedString("Tracks", comment: "Title of the tracks list section")
            case .routes: return NSLocalizedString("Routes", comment: "Title of the routes list section")
            case .waypoints: return NSLocalizedString("Waypoints", comment: "Title of the waypoints list section")
            }
        }
    }

    let selectedPaths = Bindable<[GpxPathProvider]>([])
    let selectedWaypoints = Bindable<[GpxWaypointEntity]>([])

    private weak var delegate: MapDisplayDelegate?
    private weak var gpxFileProvider: GpxFileProviding?
    private var fileEntity: GpxFileEntity?
    private var selectedTrackIndexes = Set<Int>()
    private var selectedRouteIndexes = Set<Int>()
    private var selectedWaypointIndexes = Set<Int>()

    init(delegate: MapDisplayDelegate, gpxFileProvider: GpxFileProviding) {
        self.delegate = delegate
        self.gpxFileProvider = gpxFileProvider
    }

    func updateGpxFileEntity(with file: GpxFileEntity) {
        fileEntity = file
        selectedPaths.value = []
        selectedWaypoints.value = []
        selectedTrackIndexes.removeAll()
        selectedRouteIndexes.removeAll()
        selectedWaypointIndexes.removeAll()
    }

    func numberOfRows(in section: Section) -> Int {
        switch section {
        case .tracks: return fileEntity?.tracks?.count ?? 0
        case .routes: return fileEntity?.routes?.count ?? 0
        case .waypoints: return fileEntity?.waypoints?.count ?? 0
        }
    }

    func rowProperties(for indexPath: IndexPath) -> (title: String, subtitle: String?, isSelected: Bool)? {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure()
            Logger.error(category: .viewModel, "Unexpected section number: \(indexPath.section)")
            return nil
        }
        let row = indexPath.row
        let title: String
        let subtitle: String?
        let isSelected: Bool

        switch section {
        case .tracks:
            let tracks = fileEntity?.sortedTracks ?? []
            assert(row < tracks.count && row >= 0)
            title = tracks[row].name ?? Defaults.name
            subtitle = tracks[row].trackDescription
            isSelected = selectedTrackIndexes.contains(row)

        case .routes:
            let routes = fileEntity?.sortedRoutes ?? []
            assert(row < routes.count && row >= 0)
            title = routes[row].name ?? Defaults.name
            subtitle = routes[row].routeDescription
            isSelected = selectedRouteIndexes.contains(row)

        case .waypoints:
            let waypoints = fileEntity?.sortedWaypoints ?? []
            assert(row < waypoints.count && row >= 0)
            title = waypoints[row].name ?? Defaults.name
            subtitle = waypoints[row].waypointDescription
            isSelected = selectedWaypointIndexes.contains(row)
        }

        return (title, subtitle, isSelected)
    }

    func selectRow(at indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure()
            Logger.error(category: .viewModel, "Unexpected section number: \(indexPath.section)")
            return
        }
        let row = indexPath.row

        switch section {
        case .tracks:
            let tracks = fileEntity?.tracks ?? []
            assert(row < tracks.count && row >= 0)
            guard !selectedTrackIndexes.contains(row) else { return }
            selectedTrackIndexes.insert(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }

        case .routes:
            let routes = fileEntity?.routes ?? []
            assert(row < routes.count && row >= 0)
            guard !selectedRouteIndexes.contains(row) else { return }
            selectedRouteIndexes.insert(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }

        case .waypoints:
            let waypoints = fileEntity?.waypoints ?? []
            assert(row < waypoints.count && row >= 0)
            guard !selectedWaypointIndexes.contains(row) else { return }
            selectedWaypointIndexes.insert(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }
        }
    }

    func deselectRow(at indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure()
            Logger.error(category: .viewModel, "Unexpected section number: \(indexPath.section)")
            return
        }
        let row = indexPath.row

        switch section {
        case .tracks:
            guard selectedTrackIndexes.contains(row) else { return }
            selectedTrackIndexes.remove(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }

        case .routes:
            guard selectedRouteIndexes.contains(row) else { return }
            selectedRouteIndexes.remove(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }

        case .waypoints:
            guard selectedWaypointIndexes.contains(row) else { return }
            selectedWaypointIndexes.remove(row)
            gpxFileProvider?.getGpxFile() { [weak self] result in
                if case .success(let gpxFile) = result {
                    self?.selectionChanged(file: gpxFile)
                }
            }
        }
    }

    private func selectionChanged(file: GpxFile) {
        var paths = [GpxPathProvider]()
        var mapBounds: GpxBounds?

        for index in selectedTrackIndexes {
            let track = file.tracks[index]
            track.segments.forEach { paths.append($0) }
            if track.computedProperties.bounds == nil {
                track.calculateComputedProperties()
            }
            let trackBounds = track.computedProperties.bounds!
            if let b = mapBounds {
                mapBounds = b.union(with: trackBounds)
            } else {
                mapBounds = trackBounds
            }
        }

        for index in selectedRouteIndexes {
            let route = file.routes[index]
            paths.append(route)
            if route.computedProperties.bounds == nil {
                route.calculateComputedProperties()
            }
            let routeBounds = route.computedProperties.bounds!
            if let b = mapBounds {
                mapBounds = b.union(with: routeBounds)
            } else {
                mapBounds = routeBounds
            }
        }

        let waypoints = fileEntity?.sortedWaypoints ?? []
        let waypointList = selectedWaypointIndexes.map { waypoints[$0] }
        if let b = mapBounds, waypointList.count > 0 {
            let waypointBounds: GpxBounds
            if waypointList.count == 1 {
                waypointBounds = GpxBounds(forCoordinates: [waypointList[0].coordinate, waypointList[0].coordinate])
            } else {
                waypointBounds = GpxBounds(forCoordinates: waypointList.map({ $0.coordinate }))
            }
            mapBounds = b.union(with: waypointBounds)
        }

        Thread.runOnMainThread {
            self.selectedPaths.value = paths
            self.selectedWaypoints.value = waypointList
            if let b = mapBounds {
                self.delegate?.showMapArea(center: b.center, latitudeDelta: b.latitudeDelta, longitudeDelta: b.longitudeDelta)
            }
            else if waypointList.count == 1 {
                self.delegate?.showMapArea(center: waypointList.first!.coordinate, latitudinalMeters: Constants.oneThousandMetres, longitudinalMeters: Constants.oneThousandMetres)
            }
            else if waypointList.count > 1 {
                let bounds = GpxBounds(forCoordinates: waypointList.map({ $0.coordinate }))
                self.delegate?.showMapArea(center: bounds.center, latitudeDelta: bounds.latitudeDelta, longitudeDelta: bounds.longitudeDelta)
            }
        }
    }

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of track, route, or waypoint if not known")
    }

    private struct Constants {
        static let oneThousandMetres: CLLocationDistance = 1000
    }
}
