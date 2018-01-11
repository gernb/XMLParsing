//
//  RoutesListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/8/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreLocation
import Foundation

final class RoutesListViewModel {

    let selectedRoutes = Bindable<[GpxPathProvider]>([])
    let selectionBounds = Bindable<GpxBounds>(Defaults.bounds)
    private (set) var routes: [GpxRouteEntity] = []

    private weak var gpxFileProvider: GpxFileProviding?
    private var fileEntity: GpxFileEntity?
    private var selectedRouteIndexes = Set<Int>()

    init(gpxFileProvider: GpxFileProviding) {
        self.gpxFileProvider = gpxFileProvider
    }

    func updateGpxFileEntity(with file: GpxFileEntity) {
        fileEntity = file
        routes = file.sortedRoutes
        selectedRoutes.value = []
        selectedRouteIndexes.removeAll()
    }

    func rowProperties(for index: Int) -> (title: String, subtitle: String?, isSelected: Bool) {
        assert(index < routes.count && index >= 0)
        let title = routes[index].name ?? Defaults.name
        let subtitle = routes[index].routeDescription
        let isSelected = selectedRouteIndexes.contains(index)
        return (title, subtitle, isSelected)
    }

    func selectRoute(at index: Int) {
        assert(index < routes.count && index >= 0)
        guard !selectedRouteIndexes.contains(index) else { return }
        selectedRouteIndexes.insert(index)
        gpxFileProvider?.getGpxFile() { [weak self] result in
            if case .success(let gpxFile) = result {
                self?.selectedRoutesChanged(file: gpxFile)
            }
        }
    }

    func deselectRoute(at index: Int) {
        guard selectedRouteIndexes.contains(index) else { return }
        selectedRouteIndexes.remove(index)
        gpxFileProvider?.getGpxFile() { [weak self] result in
            if case .success(let gpxFile) = result {
                self?.selectedRoutesChanged(file: gpxFile)
            }
        }
    }

    private func selectedRoutesChanged(file: GpxFile) {
        var paths = [GpxPathProvider]()
        var mapBounds: GpxBounds?
        for index in selectedRouteIndexes {
            let route = file.routes[index]
            paths.append(route)
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
            self.selectedRoutes.value = paths
            if let mapBounds = mapBounds {
                self.selectionBounds.value = mapBounds
            }
        }
    }

    private struct Defaults {
        static let name = NSLocalizedString("<Unknown Name>", comment: "Default name of route if not known")
        static let bounds: GpxBounds = {
            let center = CLLocationCoordinate2D(latitude: 37.13284, longitude: -95.78558)
            let latitudeDelta: CLLocationDegrees = 42
            let longitudeDelta: CLLocationDegrees = 62
            return GpxBounds(center: center, latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }()
    }
}
