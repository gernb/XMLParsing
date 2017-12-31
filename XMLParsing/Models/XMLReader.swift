//
//  XMLReader.swift
//  XMLParsing
//
//  Created by Peter Bohac on 12/25/17.
//  Copyright © 2017 Peter Bohac. All rights reserved.
//

import Foundation

/// Represents an element of an XML document
public final class XMLNode: CustomStringConvertible, CustomDebugStringConvertible {
    /// The XML element name
    let name: String?
    /// Dictionary of attributes for this XML element
    let attributes: [String: String]?
    /// Array of child elements of this XML element
    var nodes: [XMLNode]
    /// XML-decoded string content of this XML element
    var content: String

    private let escapeContent: Bool

    /// "Pretty-printed" string representation of this XML element
    public var description: String {
        return getXmlString()
    }

    /// Shortened string representation of this XML element
    public var debugDescription: String {
        return printDebug()
    }

    /**
     Create a new `XMLNode`.

     - parameter name: (optional) XML element name.
     - parameter attributes: (optional) Array of key:value attributes.
     - parameter content: Un-escaped string content. Default value is "".
     - parameter escapeContent: Whether to wrap the content in a CData tag when generting the XML string of this element. Default is false.
     - parameter nodes: List of child elements of this node. Default is an empty list.
    */
    public init(name: String? = nil,
                attributes: [String: String]? = nil,
                content: String = "",
                escapeContent: Bool = false,
                nodes: [XMLNode] = []) {
        self.name = name
        self.attributes = attributes
        self.content = content
        self.escapeContent = escapeContent
        self.nodes = nodes
    }

    /**
     Get the string representation of this XML element.

     - parameter level: The number of tab characters to prepend each line with.
     - returns: The "pretty-printed" string representation of this XML element.
    */
    public func getXmlString(withIndentLevel level: Int = 0) -> String {
        let indent = String(repeating: "\t", count: level)
        let name = self.name ?? "NIL"
        var xml = indent
        if let attributes = attributes, attributes.count > 0 {
            xml += "<\(name) \(attributesAsString())>"
        }
        else {
            xml += "<\(name)>"
        }
        if nodes.count > 0 {
            for n in nodes {
                xml += "\n" + n.getXmlString(withIndentLevel: level + 1)
            }
            xml += "\n\(indent)</\(name)>"
        }
        else {
            if escapeContent {
                xml += wrapInCData(content)
            }
            else {
                xml += content
            }
            xml += "</\(name)>"
        }
        return xml
    }

    /**
     Helper function that places the input string in a CData tag.

     - parameter input: String to wrap.
     - returns: The string enclosed in a CData tag.
    */
    public func wrapInCData(_ input: String) -> String {
        return "<![CDATA[\(input)]]>"
    }

    /**
     Gets the first direct descendant node with the provided name.

     - parameter name: The name of the child node to get.
     - returns: The first node found, or `nil` if not found.
    */
    public func childNode(named name: String) -> XMLNode? {
        return nodes.filter({ $0.name == name }).first
    }

    private func attributesAsString() -> String {
        var string = ""
        guard let attributes = attributes else { return string }
        for a in attributes {
            string += "\(a.key)=\"\(a.value)\" "
        }
        return string.trimmingCharacters(in: .whitespaces)
    }

    private func printDebug(indentLevel: Int = 0) -> String {
        if nodes.count > 0 {
            var value = String(repeating: " ", count: indentLevel) + "<\(name ?? "{nil}")>"
            for n in nodes {
                value += "\n" + n.printDebug(indentLevel: indentLevel + 1)
            }
            value += "\n" + String(repeating: " ", count: indentLevel) + "</\(name ?? "{nil}")>"
            return value
        }
        else {
            return String(repeating: " ", count: indentLevel) + "<\(name ?? "{nil}")/>"
        }
    }
}

/// A set of helper methods to read and parse XML into `XMLNode`s.
public final class XMLReader {

    /// Errors that may be thrown by the methods of this class.
    enum Exception: Error {
        /// The file could not be opened
        case invalidFile

        /// The string could not be converted to `Data`
        case invalidContent

        /**
         The content could not be parsed successfully as XML.

         - parameter error: The error returned by the `XMLParser` class.
        */
        case parsingError(error: Error?)
    }

    /**
     Read the XML content of the provided `URL`.

     - parameter url: `URL` to read the content from.
     - returns: `XMLNode` containing the content of the provided url.
     - throws: An `Exception` if any error occurs.
    */
    static func read(contentsOf url: URL) throws -> XMLNode {
        guard let parser = XMLParser(contentsOf: url) else {
            throw Exception.invalidFile
        }

        let parserDelegate = ParserDelegate()
        parser.delegate = parserDelegate

        if parser.parse() {
            guard let node = parserDelegate.nodes.first else {
                throw Exception.parsingError(error: nil)
            }
            return node
        }

        throw Exception.parsingError(error: parser.parserError)
    }

    /**
     Read the XML content of the provided string.

     - parameter string: `String` containing the XML content to read.
     - returns: `XMLNode` containing the content of the provided string.
     - throws: An `Exception` if any error occurs.
     */
    static func read(contentsOf string: String) throws -> XMLNode {
        guard let data = string.data(using: .utf8) else {
            throw Exception.invalidContent
        }

        let parser = XMLParser(data: data)
        let parserDelegate = ParserDelegate()
        parser.delegate = parserDelegate

        if parser.parse() {
            guard let node = parserDelegate.nodes.first else {
                throw Exception.parsingError(error: nil)
            }
            return node
        }

        throw Exception.parsingError(error: parser.parserError)
    }

}

private class ParserDelegate: NSObject, XMLParserDelegate {
    var nodes = [XMLNode]()

    func parserDidStartDocument(_ parser: XMLParser) {
        Logger.verbose(category: .xmlParsing, "Started document")
        nodes.append(XMLNode())
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Logger.error(category: .xmlParsing, "\(parseError)")
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        Logger.verbose(category: .xmlParsing, "Ended document")
        assert(nodes.count == 1, "Unexpected number of nodes on the stack!")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        Logger.verbose(category: .xmlParsing, "Started element: \(elementName)")
        let element = XMLNode(name: elementName, attributes: attributeDict)
        nodes.append(element)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let node = nodes.last else {
            fatalError("Content found outside an element!")
        }
        node.content.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        Logger.verbose(category: .xmlParsing, "Ended element: \(elementName)")
        let endedNode = nodes.removeLast()
        assert(endedNode.name == elementName, "Unexpected end of element!")
        endedNode.content = endedNode.content.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let currentNode = nodes.last else {
            fatalError("No previous nodes found!")
        }
        currentNode.nodes.append(endedNode)
    }

}
