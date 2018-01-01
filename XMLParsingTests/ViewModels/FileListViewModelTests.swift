//
//  FileListViewModelTests.swift
//  XMLParsingTests
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData
import XCTest
@testable import XMLParsing

class FileListViewModelTests: XCTestCase {

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

    func testLoadDataBasic() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        for i in 1...5 {
            let name = "file #\(i)"
            let pathUrl = testDirectoryUrl.appendingPathComponent("file\(i).gpx")
            try? name.write(to: pathUrl, atomically: true, encoding: .utf8)
            let _ = GpxFileEntity(context: container.viewContext, name: name, filename: pathUrl.lastPathComponent)
        }

        let sut = FileLisViewModel(moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)

        XCTAssertEqual(sut.files.count, 0)

        sut.loadData()
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(mockDelegate.reloadViewInvoked)
            XCTAssertEqual(sut.files.count, 5)
        }
    }

    func testLoadDataWithNewFiles() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        for i in 1...3 {
            let name = "file #\(i)"
            let pathUrl = testDirectoryUrl.appendingPathComponent("file\(i).gpx")
            try? name.write(to: pathUrl, atomically: true, encoding: .utf8)
        }

        let sut = FileLisViewModel(moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)

        XCTAssertEqual(sut.files.count, 0)

        sut.loadData()
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(mockDelegate.reloadViewInvoked)
            XCTAssertEqual(sut.files.count, 3)
        }
    }

    func testLoadDateWithRemovedFiles() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        for i in 1...5 {
            let name = "file #\(i)"
            let pathUrl = testDirectoryUrl.appendingPathComponent("file\(i).gpx")
            if i % 2 == 0 {
                try? name.write(to: pathUrl, atomically: true, encoding: .utf8)
            }
            let _ = GpxFileEntity(context: container.viewContext, name: name, filename: pathUrl.lastPathComponent)
        }

        let sut = FileLisViewModel(moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)

        XCTAssertEqual(sut.files.count, 0)

        sut.loadData()
        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error)
            XCTAssertTrue(mockDelegate.reloadViewInvoked)
            XCTAssertEqual(sut.files.count, 2)

            self.container.viewContext.perform {
                let files = try? (GpxFileEntity.fetchRequest() as NSFetchRequest<GpxFileEntity>).execute()
                XCTAssertEqual(files?.count, 2)
            }
        }
    }

    func testDeleteFile() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")
        for i in 1...3 {
            let name = "file #\(i)"
            let pathUrl = testDirectoryUrl.appendingPathComponent("file\(i).gpx")
            try? name.write(to: pathUrl, atomically: true, encoding: .utf8)
            let _ = GpxFileEntity(context: container.viewContext, name: name, filename: pathUrl.lastPathComponent)
        }

        let sut = FileLisViewModel(moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()
        wait(for: [mockDelegate.exp!], timeout: 2.0)
        XCTAssertEqual(sut.files.count, 3)

        let filename = sut.files[1].path!
        var result = sut.deleteFile(atIndex: 1)

        XCTAssertTrue(result)
        XCTAssertEqual(sut.files.count, 2)
        result = sut.files.contains(where: { $0.path == filename })
        XCTAssertFalse(result)
        result = FileManager.default.fileExists(atPath: testDirectoryUrl.appendingPathComponent(filename).path)
        XCTAssertFalse(result)
    }

    func testRowProperties() {
        let mockDelegate = MockDelegate()
        mockDelegate.exp = expectation(description: "data loaded")

        let file1 = "file1.gpx"
        try? file1.write(to: testDirectoryUrl.appendingPathComponent(file1), atomically: true, encoding: .utf8)
        let fileEntity = GpxFileEntity(context: container.viewContext, name: "File 1", filename: file1)
        fileEntity.fileParsed = true
        let trackEntity = GpxTrackEntity(context: container.viewContext)
        trackEntity.sequenceNumber = 1
        trackEntity.file = fileEntity
        for i in 1...2 {
            let routeEntity = GpxRouteEntity(context: container.viewContext)
            routeEntity.sequenceNumber = Int32(i)
            routeEntity.file = fileEntity
        }
        for i in 1...3 {
            let waypointEntity = GpxWaypointEntity(context: container.viewContext, latitude: 1.0, longitude: 2.0)
            waypointEntity.sequenceNumber = Int32(i)
            waypointEntity.file = fileEntity
        }
        let file2 = "file2.gpx"
        try? file2.write(to: testDirectoryUrl.appendingPathComponent(file2), atomically: true, encoding: .utf8)
        let _ = GpxFileEntity(context: container.viewContext, name: "File 2", filename: file2)

        let sut = FileLisViewModel(moc: container.viewContext, delegate: mockDelegate, directoryUrl: testDirectoryUrl)
        sut.loadData()
        wait(for: [mockDelegate.exp!], timeout: 2.0)
        XCTAssertEqual(sut.files.count, 2)

        let row0 = sut.rowProperties(atIndex: 0)
        XCTAssertEqual(row0.title, "File 1")
        XCTAssertEqual(row0.subtitle, "1 track(s), 2 route(s), 3 waypoint(s)")

        let row1 = sut.rowProperties(atIndex: 1)
        XCTAssertEqual(row1.title, "File 2")
        XCTAssertEqual(row1.subtitle, "")
    }

    class MockDelegate: FileLisViewModelDelegate {
        var reloadViewInvoked = false
        var exp: XCTestExpectation?

        func reloadView() {
            XCTAssertTrue(Thread.isMainThread)
            reloadViewInvoked = true
            exp?.fulfill()
        }
    }
}
