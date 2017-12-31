//
//  FileListViewModel.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/28/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData
import Foundation

protocol FileLisViewModelDelegate: class {
    func reloadView()
}

final class FileLisViewModel {

    let title = Bindable(NSLocalizedString("GPX Files", comment: "Title of the files list scene"))
    let loadingViewIsHidden = Bindable(true)
    private (set) var files: [GpxFileEntity] = []

    private let moc: NSManagedObjectContext
    private let directoryUrl: URL
    private weak var delegate: FileLisViewModelDelegate?

    init(moc: NSManagedObjectContext, delegate: FileLisViewModelDelegate, directoryUrl: URL = FileUtils.documentDirectoryUrl) {
        self.moc = moc
        self.delegate = delegate
        self.directoryUrl = directoryUrl
    }

    func loadData() {
        loadingViewIsHidden.value = false
        moc.perform {
            let request: NSFetchRequest<GpxFileEntity> = GpxFileEntity.fetchRequest()
            do {
                self.files = try request.execute()

                var gpxFilesInDirectory: [URL] = []
                let directoryFiles = try FileManager.default.contentsOfDirectory(atPath: self.directoryUrl.path)
                for file in directoryFiles.map({ self.directoryUrl.appendingPathComponent($0) }) where file.pathExtension == "gpx" {
                    gpxFilesInDirectory.append(file)
                    if self.files.contains(where: { $0.path == file.lastPathComponent }) {
                        continue
                    }
                    let gpxFileEntity = GpxFileEntity(context: self.moc, name: file.deletingPathExtension().lastPathComponent, filename: file.lastPathComponent)
                    self.files.append(gpxFileEntity)
                }
                try self.moc.save()

                if self.files.count != gpxFilesInDirectory.count {
                    var newFileList: [GpxFileEntity] = []
                    for file in self.files {
                        if gpxFilesInDirectory.contains(self.directoryUrl.appendingPathComponent(file.path!)) {
                            newFileList.append(file)
                        }
                        else {
                            self.moc.delete(file)
                        }
                    }
                    try self.moc.save()
                    self.files = newFileList
                }

                self.files.sort(by: { $0.name!.lowercased() < $1.name!.lowercased() })

                Thread.runOnMainThread {
                    self.delegate?.reloadView()
                    self.loadingViewIsHidden.value = true
                }
            }
            catch let error {
                Logger.error(category: .viewModel, "\(error)")
            }
        }
    }

    func deleteFile(atIndex index: Int) -> Bool {
        assert(index < files.count && index >= 0)
        let fm = FileManager.default
        let file = files[index]
        do {
            try fm.removeItem(at: directoryUrl.appendingPathComponent(file.path!))
            moc.delete(file)
            try moc.save()
            files.remove(at: index)
            return true
        }
        catch let error {
            Logger.error(category: .viewModel, "\(error)")
            return false
        }
    }

}
