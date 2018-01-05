//
//  TrackListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData
import CoreLocation
import Foundation

protocol TrackListViewModelDelegate: class {
    func reloadView()
    func showMapArea(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees)
    func showMapArea(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance)
}

final class TrackListViewModel {

    enum ViewType {
        case tracks, routes, waypoints
    }

    let title = Bindable(Defaults.title)
    let loadingViewIsHidden = Bindable(true)
    let selectedTracks = Bindable<[GpxTrack]>([])
    let selectedRoutes = Bindable<[GpxRoute]>([])
    let selectedWaypoints = Bindable<[GpxWaypointEntity]>([])
    private (set) var tracks: [GpxTrackEntity] = []
    private (set) var routes: [GpxRouteEntity] = []
    private (set) var waypoints: [GpxWaypointEntity] = []

    private let fileEntity: GpxFileEntity
    private let moc: NSManagedObjectContext
    private let directoryUrl: URL
    private weak var delegate: TrackListViewModelDelegate?

    private var selectedTrackIndexes = Set<Int>()
    private var selectedRouteIndexes = Set<Int>()
    private var selectedWaypointIndexes = Set<Int>()

    private var currentView = ViewType.tracks
    private var gpxFile: GpxFile?

    init(file: GpxFileEntity, moc: NSManagedObjectContext, delegate: TrackListViewModelDelegate, directoryUrl: URL = FileUtils.documentDirectoryUrl) {
        self.fileEntity = file
        self.moc = moc
        self.delegate = delegate
        self.directoryUrl = directoryUrl
    }

    func loadData() {
        title.value = fileEntity.name!
        updateLists()
        if !fileEntity.fileParsed {
            parseGpxFile()
        }
        delegate?.showMapArea(center: Defaults.mapCenter, latitudeDelta: Defaults.mapSpan.latitudeDelta, longitudeDelta: Defaults.mapSpan.longitudeDelta)
    }

    func numberOfRowsInCurrentView() -> Int {
        switch currentView {
        case .tracks:
            return tracks.count
        case.routes:
            return routes.count
        case .waypoints:
            return waypoints.count
        }
    }

    func rowProperties(atIndex index: Int) -> (title: String, isSelected: Bool) {
        var title: String
        var isSelected = false
        switch currentView {
        case .tracks:
            assert(index < tracks.count && index >= 0)
            title = tracks[index].name ?? Defaults.name
            isSelected = selectedTrackIndexes.contains(index)
        case .routes:
            assert(index < routes.count && index >= 0)
            title = routes[index].name ?? Defaults.name
            isSelected = selectedRouteIndexes.contains(index)
        case .waypoints:
            assert(index < waypoints.count && index >= 0)
            title = waypoints[index].name ?? Defaults.name
            isSelected = selectedWaypointIndexes.contains(index)
        }
        return (title, isSelected)
    }

    func viewChanged(to type: ViewType) {
        guard currentView != type else { return }

        currentView = type
        selectedTracks.value = []
        selectedRoutes.value = []
        selectedWaypoints.value = []

        switch currentView {
        case .tracks:
            selectedTracksChanged()
        case .routes:
            selectedRoutesChanged()
        case .waypoints:
            selectedWaypointsChanged()
        }
    }

    func selectTrack(atIndex index: Int) {
        assert(index < tracks.count && index >= 0)
        guard !selectedTrackIndexes.contains(index) else { return }
        selectedTrackIndexes.insert(index)

        if let _ = gpxFile {
            selectedTracksChanged()
            return
        }

        loadingViewIsHidden.value = false
        let fileUrl = self.directoryUrl.appendingPathComponent(self.fileEntity.path!)
        GpxFile.read(fromUrl: fileUrl) { [weak self] result in
            switch result {
            case .success(let file):
                self?.gpxFile = file
            case.failure(let error):
                Logger.error(category: .viewModel, "\(error)")
            }
            Thread.runOnMainThread {
                guard let strongSelf = self else { return }
                strongSelf.loadingViewIsHidden.value = true
                if let _ = strongSelf.gpxFile {
                    strongSelf.selectedTracksChanged()
                }
            }
        }
    }

    func deselectTrack(atIndex index: Int) {
        guard selectedTrackIndexes.contains(index) else { return }
        selectedTrackIndexes.remove(index)
        selectedTracksChanged()
    }

    func selectRoute(atIndex index: Int) {
        assert(index < routes.count && index >= 0)
        guard !selectedRouteIndexes.contains(index) else { return }
        selectedRouteIndexes.insert(index)

        if let _ = gpxFile {
            selectedRoutesChanged()
            return
        }

        loadingViewIsHidden.value = false
        let fileUrl = self.directoryUrl.appendingPathComponent(self.fileEntity.path!)
        GpxFile.read(fromUrl: fileUrl) { [weak self] result in
            switch result {
            case .success(let file):
                self?.gpxFile = file
            case.failure(let error):
                Logger.error(category: .viewModel, "\(error)")
            }
            Thread.runOnMainThread {
                guard let strongSelf = self else { return }
                strongSelf.loadingViewIsHidden.value = true
                if let _ = strongSelf.gpxFile {
                    strongSelf.selectedRoutesChanged()
                }
            }
        }
    }

    func deselectRoute(atIndex index: Int) {
        guard selectedRouteIndexes.contains(index) else { return }
        selectedRouteIndexes.remove(index)
        selectedTracksChanged()
    }

    func selectWaypoint(atIndex index: Int) {
        assert(index < waypoints.count && index >= 0)
        guard !selectedWaypointIndexes.contains(index) else { return }
        selectedWaypointIndexes.insert(index)
        selectedWaypointsChanged()
    }

    func deselectWaypoint(atIndex index: Int) {
        guard selectedWaypointIndexes.contains(index) else { return }
        selectedWaypointIndexes.remove(index)
        selectedWaypointsChanged()
    }

    // MARK: - Private functions

    private func updateLists() {
        tracks = (fileEntity.tracks!.allObjects as! [GpxTrackEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
        routes = (fileEntity.routes!.allObjects as! [GpxRouteEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
        waypoints = (fileEntity.waypoints!.allObjects as! [GpxWaypointEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }

    private func parseGpxFile() {
        loadingViewIsHidden.value = false
        guard let path = self.fileEntity.path else { return }
        let fileUrl = self.directoryUrl.appendingPathComponent(path)
        GpxFile.read(fromUrl: fileUrl) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let file):
                strongSelf.gpxFile = file

            case .failure(let error):
                Logger.error(category: .viewModel, "\(error)")
            }

            if let gpxFile = strongSelf.gpxFile {
                strongSelf.fileEntity.parse(file: gpxFile)
                try? strongSelf.moc.save()
                strongSelf.updateLists()
                Thread.runOnMainThread {
                    strongSelf.loadingViewIsHidden.value = true
                    strongSelf.delegate?.reloadView()
                }
            }
        }
    }

    private func selectedTracksChanged() {
        guard let file = gpxFile else { return }

        var tracks = [GpxTrack]()
        var mapBounds: GpxBounds?
        for index in selectedTrackIndexes {
            let track = file.tracks[index]
            tracks.append(track)
            if track.computedProperties.bounds == nil {
                track.calculateComputedProperties()
            }
            let trackBounds = track.computedProperties.bounds!
            if let b = mapBounds {
                mapBounds = b.union(with: trackBounds)
            }
            else {
                mapBounds = trackBounds
            }
        }

        Thread.runOnMainThread {
            self.selectedTracks.value = tracks
            if let b = mapBounds {
                self.delegate?.showMapArea(center: b.center, latitudeDelta: b.latitudeDelta, longitudeDelta: b.longitudeDelta)
            }
        }
    }

    private func selectedRoutesChanged() {
        guard let file = gpxFile else { return }

        var routes = [GpxRoute]()
        var mapBounds: GpxBounds?
        for index in selectedRouteIndexes {
            let route = file.routes[index]
            routes.append(route)
            if route.computedProperties.bounds == nil {
                route.calculateComputedProperties()
            }
            let routeBounds = route.computedProperties.bounds!
            if let b = mapBounds {
                mapBounds = b.union(with: routeBounds)
            }
            else {
                mapBounds = routeBounds
            }
        }

        Thread.runOnMainThread {
            self.selectedRoutes.value = routes
            if let b = mapBounds {
                self.delegate?.showMapArea(center: b.center, latitudeDelta: b.latitudeDelta, longitudeDelta: b.longitudeDelta)
            }
        }
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
        static let title = NSLocalizedString("GPX Tracks", comment: "Title of the tracks list scene")
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of track/route/waypoint if not known")
        static let mapCenter = CLLocationCoordinate2D(latitude: 37.13284, longitude: -95.78558)
        struct mapSpan {
            static let latitudeDelta: CLLocationDegrees = 42
            static let longitudeDelta: CLLocationDegrees = 62
        }
    }

    private struct Constants {
        static let oneThousandMetres: CLLocationDistance = 1000
    }
}
