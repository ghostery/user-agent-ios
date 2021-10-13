/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import Fuzi

private let TypeSearch = "text/html"
private let TypeSuggest = "application/x-suggestions+json"

class OpenSearchEngine: NSObject, NSCoding {
    static let PreferredIconSize = 30

    let shortName: String
    let engineID: String?
    let image: UIImage?
    let isCustomEngine: Bool
    let searchTemplate: String
    fileprivate let suggestTemplate: String?

    fileprivate let SearchTermComponent = "{searchTerms}"
    fileprivate let LocaleTermComponent = "{moz:locale}"

    fileprivate lazy var searchQueryComponentKey: String? = self.getQueryArgFromTemplate()

    init(engineID: String?, shortName: String, image: UIImage?, searchTemplate: String, suggestTemplate: String?, isCustomEngine: Bool) {
        self.shortName = shortName
        self.image = image
        self.searchTemplate = searchTemplate
        self.suggestTemplate = suggestTemplate
        self.isCustomEngine = isCustomEngine
        self.engineID = engineID
    }

    required init?(coder aDecoder: NSCoder) {
        // this catches the cases where bool encoded in Swift 2 needs to be decoded with decodeObject, but a Bool encoded in swift 3 needs
        // to be decoded using decodeBool. This catches the upgrade case to ensure that we are always able to fetch a keyed valye for isCustomEngine
        // http://stackoverflow.com/a/40034694
        let isCustomEngine = aDecoder.decodeAsBool(forKey: "isCustomEngine")
        guard let searchTemplate = aDecoder.decodeObject(forKey: "searchTemplate") as? String,
            let shortName = aDecoder.decodeObject(forKey: "shortName") as? String else {
                assertionFailure()
                return nil
        }

        self.searchTemplate = searchTemplate
        self.shortName = shortName
        self.isCustomEngine = isCustomEngine
        self.engineID = aDecoder.decodeObject(forKey: "engineID") as? String
        self.suggestTemplate = nil
        self.image = aDecoder.decodeObject(forKey: "image") as? UIImage
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(searchTemplate, forKey: "searchTemplate")
        aCoder.encode(shortName, forKey: "shortName")
        aCoder.encode(isCustomEngine, forKey: "isCustomEngine")
        aCoder.encode(engineID, forKey: "engineID")
        aCoder.encode(image, forKey: "image")
    }

    /**
     * Returns the search URL for the given query.
     */
    func searchURLForQuery(_ query: String) -> URL? {
        return getURLFromTemplate(searchTemplate, query: query)
    }

    /**
     * Return the arg that we use for searching for this engine
     * Problem: the search terms may not be a query arg, they may be part of the URL - how to deal with this?
     **/
    fileprivate func getQueryArgFromTemplate() -> String? {
        // we have the replace the templates SearchTermComponent in order to make the template
        // a valid URL, otherwise we cannot do the conversion to NSURLComponents
        // and have to do flaky pattern matching instead.
        let placeholder = "PLACEHOLDER"
        let template = searchTemplate.replacingOccurrences(of: SearchTermComponent, with: placeholder)
        var components = URLComponents(string: template)

        if let retVal = extractQueryArg(in: components?.queryItems, for: placeholder) {
            return retVal
        } else {
            // Query arg may be exist inside fragment
            components = URLComponents()
            components?.query = URL(string: template)?.fragment
            return extractQueryArg(in: components?.queryItems, for: placeholder)
        }
    }

    fileprivate func extractQueryArg(in queryItems: [URLQueryItem]?, for placeholder: String) -> String? {
        let searchTerm = queryItems?.filter { item in
            return item.value == placeholder
        }
        return searchTerm?.first?.name
    }

    /**
     * check that the URL host contains the name of the search engine somewhere inside it
     **/
    fileprivate func isSearchURLForEngine(_ url: URL?) -> Bool {
        guard let urlHost = url?.shortDisplayString,
            let queryEndIndex = searchTemplate.range(of: "?")?.lowerBound,
            let templateURL = URL(string: String(searchTemplate[..<queryEndIndex])) else { return false }
        return urlHost == templateURL.shortDisplayString
    }

    /**
     * Returns the query that was used to construct a given search URL
     **/
    func queryForSearchURL(_ url: URL?) -> String? {
        guard isSearchURLForEngine(url), let key = searchQueryComponentKey else { return nil }

        if let value = url?.getQuery()[key] {
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        } else {
            // If search term could not found in query, it may be exist inside fragment
            var components = URLComponents()
            components.query = url?.fragment?.removingPercentEncoding

            guard let value = components.url?.getQuery()[key] else { return nil }
            return value.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
        }
    }

    /**
     * Returns the search suggestion URL for the given query.
     */
    func suggestURLForQuery(_ query: String) -> URL? {
        if let suggestTemplate = suggestTemplate {
            return getURLFromTemplate(suggestTemplate, query: query)
        }
        return nil
    }

    fileprivate func getURLFromTemplate(_ searchTemplate: String, query: String) -> URL? {
        if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .SearchTermsAllowed) {
            // Escape the search template as well in case it contains not-safe characters like symbols
           let templateAllowedSet = NSMutableCharacterSet()
            templateAllowedSet.formUnion(with: .URLAllowed)

            // Allow brackets since we use them in our template as our insertion point
            templateAllowedSet.formUnion(with: CharacterSet(charactersIn: "{}"))

            if let encodedSearchTemplate = searchTemplate.addingPercentEncoding(withAllowedCharacters: templateAllowedSet as CharacterSet) {
                let localeString = Locale.current.identifier
                let urlString = encodedSearchTemplate
                    .replacingOccurrences(of: SearchTermComponent, with: escapedQuery, options: .literal, range: nil)
                    .replacingOccurrences(of: LocaleTermComponent, with: localeString, options: .literal, range: nil)
                return URL(string: urlString)
            }
        }

        return nil
    }
}

/**
 * OpenSearch XML parser.
 *
 * This parser accepts standards-compliant OpenSearch 1.1 XML documents in addition to
 * the Firefox-specific search plugin format.
 *
 * OpenSearch spec: http://www.opensearch.org/Specifications/OpenSearch/1.1
 */
class OpenSearchParser {
    fileprivate let pluginMode: Bool

    init(pluginMode: Bool) {
        self.pluginMode = pluginMode
    }

    func parse(_ file: String, engineID: String) -> OpenSearchEngine? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: file)) else {
            print("Invalid search file")
            return nil
        }

        guard let indexer = try? XMLDocument(data: data),
            let docIndexer = indexer.root else {
                print("Invalid XML document")
                return nil
        }

        let shortNameIndexer = docIndexer.children(tag: "ShortName")
        if shortNameIndexer.count != 1 {
            print("ShortName must appear exactly once")
            return nil
        }

        let shortName = shortNameIndexer[0].stringValue
        if shortName.isEmpty {
            print("ShortName must contain text")
            return nil
        }

        let urlIndexers = docIndexer.children(tag: "Url")
        if urlIndexers.isEmpty {
            print("Url must appear at least once")
            return nil
        }

        var searchTemplate: String!
        var suggestTemplate: String?
        for urlIndexer in urlIndexers {
            let type = urlIndexer.attributes["type"]
            if type == nil {
                print("Url element requires a type attribute", terminator: "\n")
                return nil
            }

            if type != TypeSearch && type != TypeSuggest {
                // Not a supported search type.
                continue
            }

            var template = urlIndexer.attributes["template"]
            if template == nil {
                print("Url element requires a template attribute", terminator: "\n")
                return nil
            }

            if pluginMode {
                let paramIndexers = urlIndexer.children(tag: "Param")

                if !paramIndexers.isEmpty {
                    template! += "?"
                    var firstAdded = false
                    for paramIndexer in paramIndexers {
                        if firstAdded {
                            template! += "&"
                        } else {
                            firstAdded = true
                        }

                        let name = paramIndexer.attributes["name"]
                        let value = paramIndexer.attributes["value"]
                        if name == nil || value == nil {
                            print("Param element must have name and value attributes", terminator: "\n")
                            return nil
                        }
                        template! += name! + "=" + value!
                    }
                }
            }

            if type == TypeSearch {
                searchTemplate = template
            } else {
                suggestTemplate = template
            }
        }

        if searchTemplate == nil {
            print("Search engine must have a text/html type")
            return nil
        }

        let uiImage: UIImage?

        switch Features.Icons.type {
        case .cliqz:
            uiImage = nil
        case .favicon:
            let imageIndexers = docIndexer.children(tag: "Image")
            var largestImage = 0
            var largestImageElement: XMLElement?

            for imageIndexer in imageIndexers {
                let imageWidth = Int(imageIndexer.attributes["width"] ?? "")
                let imageHeight = Int(imageIndexer.attributes["height"] ?? "")

                // Only accept square images.
                if imageWidth != imageHeight {
                    continue
                }

                if let imageWidth = imageWidth {
                    if imageWidth > largestImage {
                        largestImage = imageWidth
                        largestImageElement = imageIndexer
                    }
                }
            }

            if let imageElement = largestImageElement,
                let imageURL = URL(string: imageElement.stringValue),
                let imageData = try? Data(contentsOf: imageURL),
                let image = UIImage.imageFromDataThreadSafe(imageData) {
                uiImage = image
            } else {
                print("Error: Invalid search image data")
                return nil
            }
        }

        return OpenSearchEngine(engineID: engineID, shortName: shortName, image: uiImage, searchTemplate: searchTemplate, suggestTemplate: suggestTemplate, isCustomEngine: false)
    }
}

// Cliqz: extension for serializing OpenSearchEngine
extension OpenSearchEngine {
    func toDictionary(isDefault: Bool) -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = shortName
        dict["SearchTermComponent"] = SearchTermComponent
        dict["LocaleTermComponent"] = LocaleTermComponent
        dict["base_url"] = searchTemplate
        dict["default"] = isDefault
        dict["urls"] = ["text/html": searchTemplate, "application/x-suggestions+json": suggestTemplate]
        return dict
    }
}
