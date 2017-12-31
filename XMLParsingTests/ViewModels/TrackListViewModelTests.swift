//
//  TrackListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData
import CoreLocation
import XCTest
@testable import XMLParsing

class TrackListViewModelTests: XCTestCase {

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

    func testLoadDataAlreadyInCoreData() {
        let mockDelegate = MockDelegate()
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.file = fileEntity

        let sut = TrackListViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        XCTAssertEqual(sut.title.value, "File Name")
        XCTAssertTrue(sut.loadingViewIsHidden.value)
        XCTAssertEqual(sut.tracks.count, 1)
        XCTAssertEqual(sut.tracks[0].name, "Track Name")
    }

    func testLoadDataLoadsFile() {
        let mockDelegate = MockDelegate()
        mockDelegate.dataLoadedExp = expectation(description: "loadData invoked")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "file.gpx")
        try? TestContent.gpxWithTwoTracks.write(to: testDirectoryUrl.appendingPathComponent(fileEntity.path!), atomically: true, encoding: .utf8)

        let sut = TrackListViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.title.value, "File Name")
            XCTAssertTrue(sut.loadingViewIsHidden.value)
            XCTAssertEqual(sut.tracks.count, 2)
            XCTAssertEqual(sut.tracks[0].name, "Track 1")
            XCTAssertEqual(sut.tracks[1].name, "Track 2")
        }
    }

    func testSelectTrackWithFileAlreadyLoaded() {
        let mockDelegate = MockDelegate()
        mockDelegate.dataLoadedExp = expectation(description: "loadData invoked")
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "file.gpx")
        try? TestContent.gpxWithOneTrack.write(to: testDirectoryUrl.appendingPathComponent(fileEntity.path!), atomically: true, encoding: .utf8)

        let sut = TrackListViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()
        wait(for: [mockDelegate.dataLoadedExp!], timeout: 2.0)

        sut.selectTrack(atIndex: 0)

        XCTAssertTrue(mockDelegate.showMapAreaInvoked)
        XCTAssertEqual(sut.selectedTracks.value.count, 1)
    }

    func testSelectTrackLoadsFile() {
        let mockDelegate = MockDelegate()
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "file.gpx")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track A"
        trackEntity.file = fileEntity
        try? TestContent.gpxWithOneTrack.write(to: testDirectoryUrl.appendingPathComponent(fileEntity.path!), atomically: true, encoding: .utf8)

        let sut = TrackListViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()
        XCTAssertEqual(sut.tracks.count, 1)

        mockDelegate.showMapAreaExp = expectation(description: "showMapArea invoked")
        sut.selectTrack(atIndex: 0)

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.selectedTracks.value.count, 1)
        }
    }

    func testSelectWaypoint() {
        let mockDelegate = MockDelegate()
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let wptEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
        wptEntity.name = "Waypoint Name"
        wptEntity.file = fileEntity

        let sut = TrackListViewModel(file: fileEntity, moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()
        XCTAssertEqual(sut.waypoints.count, 1)

        sut.selectWaypoint(atIndex: 0)

        XCTAssertTrue(mockDelegate.showMapAreaInvoked)
        XCTAssertEqual(sut.selectedWaypoints.value.count, 1)
        XCTAssertEqual(sut.selectedWaypoints.value[0].name, wptEntity.name)
    }

    class MockDelegate: TrackListViewModelDelegate {
        var reloadViewInvoked = false
        var showMapAreaInvoked = false
        var dataLoadedExp: XCTestExpectation?
        var showMapAreaExp: XCTestExpectation?

        func reloadView() {
            XCTAssertTrue(Thread.isMainThread)
            reloadViewInvoked = true
            dataLoadedExp?.fulfill()
        }

        func showMapArea(center: CLLocationCoordinate2D, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees) {
            XCTAssertTrue(Thread.isMainThread)
            showMapAreaInvoked = true
            showMapAreaExp?.fulfill()
        }

        func showMapArea(center: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {
            XCTAssertTrue(Thread.isMainThread)
            showMapAreaInvoked = true
            showMapAreaExp?.fulfill()
        }
    }

    struct TestContent {
        static let gpxWithOneTrack = """
            <gpx version="1.1">
              <trk>
                <name><![CDATA[Track A]]></name>
                <desc><![CDATA[Track A Description]]></desc>
              </trk>
            </gpx>
            """
        static let gpxWithTwoTracks = """
            <gpx version="1.1">
              <trk>
                <name><![CDATA[Track 1]]></name>
                <desc><![CDATA[Track 1 Description]]></desc>
              </trk>
              <trk>
                <name><![CDATA[Track 2]]></name>
                <desc><![CDATA[Track 2 Description]]></desc>
              </trk>
            </gpx>
            """
    }
}
