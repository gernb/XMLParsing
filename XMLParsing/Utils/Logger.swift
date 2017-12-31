//
//  Logger.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/29/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

final class Logger {
    enum LogLevel: Int, CustomStringConvertible {
        case verbose
        case info
        case warning
        case error

        var description: String {
            switch self {
            case .verbose:  return "[V]📌"
            case .info:     return "[I]🔮"
            case .warning:  return "[W]❓"
            case .error:    return "[E]‼️"
            }
        }
    }

    struct Category: OptionSet {
        static let model = Category(rawValue: 1 << 0)
        static let viewModel = Category(rawValue: 1 << 1)
        static let view = Category(rawValue: 1 << 2)
        static let xmlParsing = Category(rawValue: 1 << 3)
        static let utility = Category(rawValue: 1 << 4)

        static let all: Category = [.model, .viewModel, .view, .xmlParsing, .utility]

        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue }
    }

    static var level: LogLevel = .verbose
    static var categories: Category = .all

    static func verbose(category: Category, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(logLevel: .verbose, category: category, message, file: file, function: function, line: line)
    }

    static func info(category: Category, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(logLevel: .info, category: category, message, file: file, function: function, line: line)
    }

    static func warning(category: Category, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(logLevel: .warning, category: category, message, file: file, function: function, line: line)
    }

    static func error(category: Category, _ message: @autoclosure () -> String, file: String = #file, function: String = #function, line: Int = #line) {
        log(logLevel: .error, category: category, message, file: file, function: function, line: line)
    }

    private static func log(logLevel: LogLevel, category: Category, _ message: () -> String, file: String, function: String, line: Int) {
        guard logLevel.rawValue >= level.rawValue else { return }
        guard categories.contains(category) else { return }

        let text = message()
        let filename = (file as NSString).lastPathComponent
        NSLog("\(logLevel.description) \(filename):\(line) [\(function)] -> \(text)")
    }

}
