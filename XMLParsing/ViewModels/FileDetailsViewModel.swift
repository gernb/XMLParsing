//
//  FileDetailsViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 1/6/18.
//  Copyright © 2018 Peter Bohac. All rights reserved.
//

import CoreData
import Foundation

protocol FileDetailsViewModelDelegate: class {
    func dataLoaded(defaultListResult: Result<FileDetailsViewModel.ListType>)
}

protocol GpxFileProviding: class {
    func getGpxFile(completion: @escaping (Result<GpxFile>) -> Void)
}

final class FileDetailsViewModel {

    enum ListType {
        case all, tracks, routes, waypoints
    }
    enum Exception: Error {
        case FileReadFailed(Error)
        case FileEmpty
    }

    let title = Bindable(Defaults.title)
    let loadingViewIsHidden = Bindable(true)
    let fileEntity: GpxFileEntity

    private let moc: NSManagedObjectContext
    private let directoryUrl: URL
    private weak var delegate: FileDetailsViewModelDelegate?
    private var gpxFile: GpxFile?

    init(file: GpxFileEntity, moc: NSManagedObjectContext, delegate: FileDetailsViewModelDelegate, directoryUrl: URL = FileUtils.documentDirectoryUrl) {
        self.fileEntity = file
        self.moc = moc
        self.delegate = delegate
        self.directoryUrl = directoryUrl
    }

    func loadData() {
        if let fileName = fileEntity.name {
            title.value = fileName
        }
        if !fileEntity.fileParsed {
            parseGpxFile()
        } else {
            let defaultList = determineDefaultList()
            delegate?.dataLoaded(defaultListResult: .success(defaultList))
        }
    }

    private func determineDefaultList() -> ListType {
        let tracksCount = fileEntity.tracks?.count ?? 0
        let routesCount = fileEntity.routes?.count ?? 0
        let waypointsCount = fileEntity.waypoints?.count ?? 0

        switch (tracksCount, routesCount, waypointsCount) {
        case (0, 0, 0):
            return .all
        case (_, 0, 0):
            return .tracks
        case (0, _, 0):
            return .routes
        case (0, 0, _):
            return .waypoints
        case (_, _, _):
            return .all
        }
    }

    private func parseGpxFile() {
        loadingViewIsHidden.value = false
        guard let path = fileEntity.path else { return }
        let fileUrl = directoryUrl.appendingPathComponent(path)
        GpxFile.read(fromUrl: fileUrl) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let file):
                strongSelf.gpxFile = file

            case .failure(let error):
                Logger.error(category: .viewModel, "\(error)")
                strongSelf.delegate?.dataLoaded(defaultListResult: .failure(Exception.FileReadFailed(error)))
                return
            }

            if let gpxFile = strongSelf.gpxFile {
                strongSelf.fileEntity.parse(file: gpxFile)
                try? strongSelf.moc.save()
                Thread.runOnMainThread {
                    strongSelf.loadingViewIsHidden.value = true
                    let defaultList = strongSelf.determineDefaultList()
                    strongSelf.delegate?.dataLoaded(defaultListResult: .success(defaultList))
                }
            } else {
                strongSelf.delegate?.dataLoaded(defaultListResult: .failure(Exception.FileEmpty))
            }
        }
    }

    private struct Defaults {
        static let title = NSLocalizedString("GPX File", comment: "Default title of the file details scene")
    }
}

extension FileDetailsViewModel: GpxFileProviding {

    func getGpxFile(completion: @escaping (Result<GpxFile>) -> Void) {
        if let gpxFile = gpxFile {
            completion(.success(gpxFile))
            return
        }

        loadingViewIsHidden.value = false
        let fileUrl = directoryUrl.appendingPathComponent(fileEntity.path!)
        GpxFile.read(fromUrl: fileUrl) { [weak self] result in
            Thread.runOnMainThread {
                self?.loadingViewIsHidden.value = true
            }
            switch result {
            case .success(let file):
                self?.gpxFile = file
                completion(.success(file))
            case.failure(let error):
                Logger.error(category: .viewModel, "\(error)")
                completion(.failure(error))
            }
        }
    }
}
