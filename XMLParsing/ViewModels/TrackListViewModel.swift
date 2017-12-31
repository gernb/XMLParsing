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

    let title = Bindable(NSLocalizedString("GPX Tracks", comment: "Title of the tracks list scene"))
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

    private var gpxFile: GpxFile?

    init(file: GpxFileEntity, moc: NSManagedObjectContext, delegate: TrackListViewModelDelegate, directoryUrl: URL = FileUtils.documentDirectoryUrl) {
        self.fileEntity = file
        self.moc = moc
        self.delegate = delegate
        self.directoryUrl = directoryUrl
    }

    func loadData() {
        title.value = fileEntity.name!
        updateTracksList()
        updateRoutesList()
        updateWaypointsList()
        if !fileEntity.fileParsed {
            parseGpxFile()
        }
        delegate?.showMapArea(center: Defaults.mapCenter, latitudeDelta: Defaults.mapSpan.latitudeDelta, longitudeDelta: Defaults.mapSpan.longitudeDelta)
    }

    func selectTrack(atIndex index: Int) {
        assert(index < tracks.count && index >= 0)

        let selectedTrackChanged: () -> Void = { [weak self] in
            guard let strongSelf = self, let file = strongSelf.gpxFile else { return }
            let track = file.tracks[index]
            strongSelf.selectedTracks.value = [track]
            if track.computedProperties.bounds == nil {
                track.calculateComputedProperties()
            }
            let center = track.computedProperties.center!
            let bounds = track.computedProperties.bounds!
            strongSelf.delegate?.showMapArea(center: center, latitudeDelta: bounds.maxLat - bounds.minLat, longitudeDelta: bounds.maxLon - bounds.minLon)
            print(track.computedProperties.duration!)
            print(track.computedProperties.distance!)
        }

        if let _ = gpxFile {
            selectedTrackChanged()
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
                    selectedTrackChanged()
                }
            }
        }
    }

    func selectRoute(atIndex index: Int) {
        assert(index < routes.count && index >= 0)

        let selectedRouteChanged: () -> Void = { [weak self] in
            guard let strongSelf = self, let file = strongSelf.gpxFile else { return }
            let route = file.routes[index]
            strongSelf.selectedRoutes.value = [route]
            if route.computedProperties.bounds == nil {
                route.calculateComputedProperties()
            }
            let center = route.computedProperties.center!
            let bounds = route.computedProperties.bounds!
            strongSelf.delegate?.showMapArea(center: center, latitudeDelta: bounds.maxLat - bounds.minLat, longitudeDelta: bounds.maxLon - bounds.minLon)
            print(route.computedProperties.duration!)
            print(route.computedProperties.distance!)
        }

        if let _ = gpxFile {
            selectedRouteChanged()
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
                    selectedRouteChanged()
                }
            }
        }
    }

    func selectWaypoint(atIndex index: Int) {
        assert(index < waypoints.count && index >= 0)

        let waypoint = waypoints[index]
        selectedWaypoints.value = [waypoint]
        delegate?.showMapArea(center: waypoint.coordinate, latitudinalMeters: Constants.oneThousandMetres, longitudinalMeters: Constants.oneThousandMetres)
    }

    private func updateTracksList() {
        tracks = (fileEntity.tracks!.allObjects as! [GpxTrackEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }

    private func updateRoutesList() {
        routes = (fileEntity.routes!.allObjects as! [GpxRouteEntity]).sorted(by: { $0.sequenceNumber < $1.sequenceNumber })
    }

    private func updateWaypointsList() {
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
                strongSelf.updateTracksList()
                strongSelf.updateRoutesList()
                strongSelf.updateWaypointsList()
                Thread.runOnMainThread {
                    strongSelf.loadingViewIsHidden.value = true
                    strongSelf.delegate?.reloadView()
                }
            }
        }
    }

    private struct Defaults {
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
