//
//  WaypointsListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/7/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class WaypointsListViewModelTests: XCTestCase {

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
        let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.file = fileEntity
        let sut = WaypointsListViewModel()

        XCTAssertEqual(sut.waypoints, [])
        XCTAssertEqual(sut.selectedWaypoints.value, [])

        sut.updateGpxFileEntity(with: fileEntity)

        XCTAssertEqual(sut.waypoints, [waypointEntity])
        XCTAssertEqual(sut.selectedWaypoints.value, [])
    }

    func testRowProperties() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.waypointDescription = #function
        waypointEntity.file = fileEntity
        let sut = WaypointsListViewModel()
        sut.updateGpxFileEntity(with: fileEntity)

        var props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Waypoint Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertFalse(props.isSelected)

        sut.selectWaypoint(at: 0)
        props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Waypoint Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertTrue(props.isSelected)
    }

    func testSelectWaypoint() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.waypointDescription = #function
        waypointEntity.file = fileEntity
        let sut = WaypointsListViewModel()
        sut.updateGpxFileEntity(with: fileEntity)

        XCTAssertEqual(sut.selectedWaypoints.value, [])

        sut.selectWaypoint(at: 0)

        XCTAssertEqual(sut.selectedWaypoints.value, [waypointEntity])

        sut.deselectWaypoint(at: 0)

        XCTAssertEqual(sut.selectedWaypoints.value, [])
    }
}
