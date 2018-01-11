//
//  TracksListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 1/10/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class TracksListViewModelTests: XCTestCase {

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
        let mockDelegate = MockMapDisplayDelegate()
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = TracksListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)

        XCTAssertEqual(sut.tracks, [])
        XCTAssertEqual(sut.selectedTracks.value.count, 0)

        sut.updateGpxFileEntity(with: fileEntity)

        XCTAssertEqual(sut.tracks, [trackEntity])
        XCTAssertEqual(sut.selectedTracks.value.count, 0)
    }

    func testRowProperties() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.trackDescription = #function
        trackEntity.file = fileEntity
        let mockDelegate = MockMapDisplayDelegate()
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = TracksListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        let props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Track Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertFalse(props.isSelected)
    }

    func testSelectTrack() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.trackDescription = #function
        trackEntity.file = fileEntity
        let mockDelegate = MockMapDisplayDelegate()
        mockDelegate.exp = expectation(description: #function)
        let mockGpxFileProvider = MockGpxFileProvider()
        var gpxFile = GpxFile()
        gpxFile.add(track: GpxTrack(name: "Track Name", description: #function))
        mockGpxFileProvider.gpxFile = gpxFile
        let sut = TracksListViewModel(delegate: mockDelegate, gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        sut.selectTrack(at: 0)

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertEqual(sut.selectedTracks.value.count, 1)
            XCTAssertEqual(sut.selectedTracks.value[0].name, "Track Name")
        }
    }
}
