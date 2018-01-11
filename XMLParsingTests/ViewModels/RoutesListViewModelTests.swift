//
//  RoutesListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/9/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class RoutesListViewModelTests: XCTestCase {

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
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.file = fileEntity
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = RoutesListViewModel(gpxFileProvider: mockGpxFileProvider)

        XCTAssertEqual(sut.routes, [])
        XCTAssertEqual(sut.selectedRoutes.value.count, 0)

        sut.updateGpxFileEntity(with: fileEntity)

        XCTAssertEqual(sut.routes, [routeEntity])
        XCTAssertEqual(sut.selectedRoutes.value.count, 0)
    }

    func testRowProperties() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.routeDescription = #function
        routeEntity.file = fileEntity
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = RoutesListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        var props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Route Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertFalse(props.isSelected)

        sut.selectRoute(at: 0)
        props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Route Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertTrue(props.isSelected)
    }

    func testSelectRoute() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.routeDescription = #function
        routeEntity.file = fileEntity

        let mockGpxFileProvider = MockGpxFileProvider()
        let gpxFile: GpxFile = {
            let pt1 = GpxWaypoint(withNodeName: .routepoint, latitude: 1.0, longitude: 2.0)
            let pt2 = GpxWaypoint(withNodeName: .routepoint, latitude: 1.1, longitude: 2.1)
            let route = GpxRoute(name: "Route Name", description: #function, points: [pt1, pt2])
            return GpxFile(routes: [route])
        }()
        mockGpxFileProvider.gpxFile = gpxFile

        var selectedRoutes = [GpxPathProvider]()
        var exp: XCTestExpectation? = nil
        let binding = Binding<[GpxPathProvider]>(setValue: { v in selectedRoutes = v; exp?.fulfill() },
                                                 getValue: { return selectedRoutes })

        let sut = RoutesListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)
        binding.bind(sut.selectedRoutes)

        exp = expectation(description: "selected routes changed")
        sut.selectRoute(at: 0)

        wait(for: [exp!], timeout: 2.0)
        XCTAssertEqual(selectedRoutes.count, 1)
        XCTAssertEqual(selectedRoutes[0].pathType, .route)

        exp = expectation(description: "selected routes changed, again")
        sut.deselectRoute(at: 0)

        wait(for: [exp!], timeout: 2.0)
        XCTAssertEqual(selectedRoutes.count, 0)
    }
}
