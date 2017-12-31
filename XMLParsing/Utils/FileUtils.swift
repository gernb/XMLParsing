//
//  FileUtils.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/26/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

final class FileUtils {

    static var documentDirectoryUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static func copyToDocuments(sourceUrl source: URL) -> URL? {
        let fm = FileManager.default

        let destinationFilename = source.lastPathComponent
        var destinationUrl = documentDirectoryUrl.appendingPathComponent(destinationFilename)
        if fm.fileExists(atPath: destinationUrl.path) {
            let fileExtension = destinationUrl.pathExtension
            let newFileName = UUID().uuidString
            destinationUrl = documentDirectoryUrl.appendingPathComponent(newFileName).appendingPathExtension(fileExtension)
        }

        do {
            try fm.copyItem(at: source, to: destinationUrl)
            return destinationUrl
        }
        catch let error {
            Logger.error(category: .utility, "\(error)")
            return nil
        }
    }
}
