//
//  FileDetailsViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/7/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class FileDetailsViewModelTests: XCTestCase {

    var container: NSPersistentContainer!
    let testDirectoryUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

    override func setUp() {
        super.setUp()

        TestUtils.cleanDirectory(testDirectoryUrl)

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

    func testLoadDataOnlyTracks() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.file = fileEntity

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .tracks)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadDataOnlyRoutes() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let routeEntity = GpxRouteEntity(context: container.viewContext)
        routeEntity.name = "Route Name"
        routeEntity.file = fileEntity

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .routes)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadDataOnlyWaypoints() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.file = fileEntity

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .waypoints)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadDataMultipleLists() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.file = fileEntity
        let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        waypointEntity.name = "Waypoint Name"
        waypointEntity.file = fileEntity

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .all)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadDataNoLists() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .all)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testLoadDataLoadsFile() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "file.gpx")
        let gpxWithTwoTracks = """
            <gpx version="1.1">
              <trk><name><![CDATA[Track 1]]></name></trk>
              <trk><name><![CDATA[Track 2]]></name></trk>
            </gpx>
            """
        try? gpxWithTwoTracks.write(to: testDirectoryUrl.appendingPathComponent(fileEntity.path!), atomically: true, encoding: .utf8)

        let sut = FileDetailsViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            switch mockDelegate.result! {
            case .success(let defaultList):
                XCTAssertEqual(defaultList, .tracks)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    private class MockDelegate: FileDetailsViewModelDelegate {
        var exp: XCTestExpectation?
        var result: Result<FileDetailsViewModel.ListType>?

        func dataLoaded(defaultListResult: Result<FileDetailsViewModel.ListType>) {
            result = defaultListResult
            exp?.fulfill()
        }
    }
}
