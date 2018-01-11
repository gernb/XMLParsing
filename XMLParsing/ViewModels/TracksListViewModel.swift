//
//  TracksListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/9/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import Foundation

final class TracksListViewModel {

    let selectedTracks = Bindable<[GpxTrack]>([])
    private (set) var tracks: [GpxTrackEntity] = []

    private weak var delegate: MapDisplayDelegate?
    private weak var gpxFileProvider: GpxFileProviding?
    private var fileEntity: GpxFileEntity?
    private var selectedTrackIndexes = Set<Int>()

    init(delegate: MapDisplayDelegate, gpxFileProvider: GpxFileProviding) {
        self.delegate = delegate
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
            } else {
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

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of track if not known")
    }
}
