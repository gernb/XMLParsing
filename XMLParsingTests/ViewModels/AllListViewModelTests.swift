//
//  AllListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/13/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class AllListViewModelTests: XCTestCase {

    var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        container = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testUpdateGpxFileEntity() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.file = fileEntity
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.file = fileEntity
        let waypointEntity = GpxWaypointEntity(context: container.viewContext)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.file = fileEntity

        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = AllListViewModel(gpxFileProvider: mockGpxFileProvider)

        XCTAssertEqual(sut.selectedPaths.value.count, 0)
        XCTAssertEqual(sut.selectedWaypoints.value.count, 0)

        sut.updateGpxFileEntity(with: fileEntity)

        XCTAssertEqual(sut.selectedPaths.value.count, 0)
        XCTAssertEqual(sut.selectedWaypoints.value.count, 0)

        let tracksCount = sut.numberOfRows(in: .tracks)
        XCTAssertEqual(tracksCount, 1)
        let routesCount = sut.numberOfRows(in: .routes)
        XCTAssertEqual(routesCount, 1)
        let waypointsCount = sut.numberOfRows(in: .waypoints)
        XCTAssertEqual(waypointsCount, 1)
    }

    func testRowProperties() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.trackDescription = "Track description"
        trackEntity.file = fileEntity
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.routeDescription = "Route description"
        routeEntity.file = fileEntity
        let waypointEntity = GpxWaypointEntity(context: container.viewContext)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.waypointDescription = "Waypoint description"
        waypointEntity.file = fileEntity

        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = AllListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        var props = sut.rowProperties(for: IndexPath(row: 0, section: AllListViewModel.Section.tracks.rawValue))

        XCTAssertNotNil(props)
        XCTAssertEqual(props?.title, "Track Name")
        XCTAssertEqual(props?.subtitle, "Track description")
        XCTAssertFalse(props!.isSelected)

        props = sut.rowProperties(for: IndexPath(row: 0, section: AllListViewModel.Section.routes.rawValue))

        XCTAssertNotNil(props)
        XCTAssertEqual(props?.title, "Route Name")
        XCTAssertEqual(props?.subtitle, "Route description")
        XCTAssertFalse(props!.isSelected)

        props = sut.rowProperties(for: IndexPath(row: 0, section: AllListViewModel.Section.waypoints.rawValue))

        XCTAssertNotNil(props)
        XCTAssertEqual(props?.title, "Waypoint Name")
        XCTAssertEqual(props?.subtitle, "Waypoint description")
        XCTAssertFalse(props!.isSelected)
    }

    func testRowSelection() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.file = fileEntity
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.file = fileEntity
        let waypointEntity = GpxWaypointEntity(context: container.viewContext)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.file = fileEntity

        let mockGpxFileProvider = MockGpxFileProvider()
        let gpxFile: GpxFile = {
            let pt1 = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)
            let pt2 = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.1, longitude: 2.1)
            let segment = GpxTrackSegment(points: [pt1, pt2])
            let track = GpxTrack(name: "Track Name", segments: [segment])
            let pt3 = GpxWaypoint(withNodeName: .routepoint, latitude: 2.0, longitude: 3.0)
            let pt4 = GpxWaypoint(withNodeName: .routepoint, latitude: 2.1, longitude: 3.1)
            let route = GpxRoute(name: "Route Name", points: [pt3, pt4])
            let waypoint = GpxWaypoint(withNodeName: .waypoint, latitude: 3.0, longitude: 4.0, name: "Waypoint Name")
            return GpxFile(waypoints: [waypoint], routes: [route], tracks: [track])
        }()
        mockGpxFileProvider.gpxFile = gpxFile

        var selectedPaths = [GpxPathProvider]()
        var pathExp: XCTestExpectation? = nil
        let pathsBinding = Binding<[GpxPathProvider]>(setValue: { v in selectedPaths = v; pathExp?.fulfill() },
                                                      getValue: { return selectedPaths })
        var selectedWaypoints = [GpxWaypointEntity]()
        var waypointExp: XCTestExpectation? = nil
        let waypointsBinding = Binding<[GpxWaypointEntity]>(setValue: { v in selectedWaypoints = v; waypointExp?.fulfill() },
                                                            getValue: { return selectedWaypoints })

        let sut = AllListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)
        pathsBinding.bind(sut.selectedPaths)
        waypointsBinding.bind(sut.selectedWaypoints)

        pathExp = expectation(description: "selected paths changed")
        sut.selectRow(at: IndexPath(row: 0, section: AllListViewModel.Section.routes.rawValue))

        wait(for: [pathExp!], timeout: 2.0)
        XCTAssertEqual(selectedPaths.count, 1)
        XCTAssertEqual(selectedPaths[0].pathType, .route)

        pathExp = nil
        waypointExp = expectation(description: "selected waypoints changed")
        sut.selectRow(at: IndexPath(row: 0, section: AllListViewModel.Section.waypoints.rawValue))

        wait(for: [waypointExp!], timeout: 2.0)
        XCTAssertEqual(selectedWaypoints, [waypointEntity])

        waypointExp = nil
        pathExp = expectation(description: "selected paths changed, again")
        sut.deselectRow(at: IndexPath(row: 0, section: AllListViewModel.Section.routes.rawValue))

        wait(for: [pathExp!], timeout: 2.0)
        XCTAssertEqual(selectedPaths.count, 0)
    }
}
