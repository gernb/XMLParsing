//
//  TracksListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/9/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreLocation
import Foundation

final class TracksListViewModel {

    let selectedTracks = Bindable<[GpxPathProvider]>([])
    let selectionBounds = Bindable<GpxBounds>(Defaults.bounds)
    private (set) var tracks: [GpxTrackEntity] = []

    private weak var gpxFileProvider: GpxFileProviding?
    private var fileEntity: GpxFileEntity?
    private var selectedTrackIndexes = Set<Int>()

    init(gpxFileProvider: GpxFileProviding) {
        self.gpxFileProvider = gpxFileProvider
    }

    func updateGpxFileEntity(with file: GpxFileEntity) {
        fileEntity = file
        tracks = file.sortedTracks
        selectedTracks.value = []
        selectedTrackIndexes.removeAll()
    }

    func rowProperties(for index: Int) -> (title: String, subtitle: String?, isSelected: Bool) {
        assert(index < tracks.count && index >= 0)
        let title = tracks[index].name ?? Defaults.name
        let subtitle = tracks[index].trackDescription
        let isSelected = selectedTrackIndexes.contains(index)
        return (title, subtitle, isSelected)
    }

    func selectTrack(at index: Int) {
        assert(index < tracks.count && index >= 0)
        guard !selectedTrackIndexes.contains(index) else { return }
        selectedTrackIndexes.insert(index)
        gpxFileProvider?.getGpxFile() { [weak self] result in
            if case .success(let gpxFile) = result {
                self?.selectedTracksChanged(file: gpxFile)
            }
        }
    }

    func deselectTrack(at index: Int) {
        guard selectedTrackIndexes.contains(index) else { return }
        selectedTrackIndexes.remove(index)
        gpxFileProvider?.getGpxFile() { [weak self] result in
            if case .success(let gpxFile) = result {
                self?.selectedTracksChanged(file: gpxFile)
            }
        }
    }

    private func selectedTracksChanged(file: GpxFile) {
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

        Thread.runOnMainThread {
            self.selectedTracks.value = paths
            if let mapBounds = mapBounds {
                self.selectionBounds.value = mapBounds
            }
        }
    }

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of track if not known")
        static let bounds: GpxBounds = {
            let center = CLLocationCoordinate2D(latitude: 37.13284, longitude: -95.78558)
            let latitudeDelta: CLLocationDegrees = 42
            let longitudeDelta: CLLocationDegrees = 62
            return GpxBounds(center: center, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }()
    }
}
