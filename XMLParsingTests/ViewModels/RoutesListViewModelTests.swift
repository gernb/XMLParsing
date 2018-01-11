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
        let mockDelegate = MockMapDisplayDelegate()
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = RoutesListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)

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
        let mockDelegate = MockMapDisplayDelegate()
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = RoutesListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        let props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Route Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertFalse(props.isSelected)
    }

    func testSelectRoute() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.routeDescription = #function
        routeEntity.file = fileEntity
        let mockDelegate = MockMapDisplayDelegate()
        mockDelegate.exp = expectation(description: #function)
        let mockGpxFileProvider = MockGpxFileProvider()
        var gpxFile = GpxFile()
        gpxFile.add(route: GpxRoute(name: "Route Name", description: #function))
        mockGpxFileProvider.gpxFile = gpxFile
        let sut = RoutesListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        sut.selectRoute(at: 0)

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.selectedRoutes.value.count, 1)
            XCTAssertEqual(sut.selectedRoutes.value[0].name, "Route Name")
        }
    }
}
