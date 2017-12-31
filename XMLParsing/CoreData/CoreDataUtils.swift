//
//  CoreDataUtils.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import CoreData

final class CoreDataUtils {

    static func loadSampleData() {
        let filesRequest: NSFetchRequest<GpxFileEntity> = GpxFileEntity.fetchRequest()
        let moc = AppDelegate.shared.coreDataContainer.viewContext
        var files: [GpxFileEntity] = []
        moc.performAndWait {
            do {
                files = try filesRequest.execute()
            }
            catch let error {
                Logger.error(category: .utility, "\(error)")
            }
        }
        guard files.count == 0 else { return }

        for file in Constants.sampleFiles {
            if let url = Bundle.main.url(forResource: file, withExtension: "gpx") {
                guard let destinationUrl = FileUtils.copyToDocuments(sourceUrl: url) else { continue }
                let sourceFilename = url.deletingPathExtension().lastPathComponent
                do {
                    let _ = GpxFileEntity(context: moc, name: sourceFilename, filename: destinationUrl.lastPathComponent)
                    try moc.save()
                }
                catch let error {
                    Logger.error(category: .utility, "\(error)")
                }
            }
        }
    }

    private struct Constants {
        static let sampleFiles = [ "bike ride with family", "Cycling - Winter 2015", "Location", "18 May 2012" ]
    }
}
