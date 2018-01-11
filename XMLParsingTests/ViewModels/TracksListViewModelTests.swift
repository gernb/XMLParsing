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
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = TracksListViewModel(gpxFileProvider: mockGpxFileProvider)

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
        let mockGpxFileProvider = MockGpxFileProvider()
        let sut = TracksListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)

        var props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Track Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertFalse(props.isSelected)

        sut.selectTrack(at: 0)
        props = sut.rowProperties(for: 0)

        XCTAssertEqual(props.title, "Track Name")
        XCTAssertEqual(props.subtitle, #function)
        XCTAssertTrue(props.isSelected)
    }

    func testSelectTrack() {
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File Name", filename: "")
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.name = "Track Name"
        trackEntity.trackDescription = #function
        trackEntity.file = fileEntity

        let mockGpxFileProvider = MockGpxFileProvider()
        let gpxFile: GpxFile = {
            let pt1 = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.0, longitude: 2.0)
            let pt2 = GpxWaypoint(withNodeName: .trackpoint, latitude: 1.1, longitude: 2.1)
            let segment = GpxTrackSegment(points: [pt1, pt2])
            let track = GpxTrack(name: "Track Name", description: #function, segments: [segment])
            return GpxFile(tracks: [track])
        }()
        mockGpxFileProvider.gpxFile = gpxFile

        var selectedTrackSegments = [GpxPathProvider]()
        var exp: XCTestExpectation? = nil
        let binding = Binding<[GpxPathProvider]>(setValue: { v in selectedTrackSegments = v; exp?.fulfill() },
                                                 getValue: { return selectedTrackSegments })

        let sut = TracksListViewModel(gpxFileProvider: mockGpxFileProvider)
        sut.updateGpxFileEntity(with: fileEntity)
        binding.bind(sut.selectedTracks)

        exp = expectation(description: "selected tracks changed")
        sut.selectTrack(at: 0)

        wait(for: [exp!], timeout: 2.0)
        XCTAssertEqual(selectedTrackSegments.count, gpxFile.tracks[0].segments.count)
        XCTAssertEqual(selectedTrackSegments[0].pathType, .trackSegment)

        exp = expectation(description: "selected tracks changed, again")
        sut.deselectTrack(at: 0)

        wait(for: [exp!], timeout: 2.0)
        XCTAssertEqual(selectedTrackSegments.count, 0)
    }
}
