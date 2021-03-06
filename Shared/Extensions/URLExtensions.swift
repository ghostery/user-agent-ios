/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import TLDExtract

let extractor = try! TLDExtract(useFrozenData: true)

// MARK: - Local Resource URL Extensions
extension URL {

    public func allocatedFileSize() -> Int64 {
        // First try to get the total allocated size and in failing that, get the file allocated size
        return getResourceLongLongForKey(URLResourceKey.totalFileAllocatedSizeKey.rawValue)
            ?? getResourceLongLongForKey(URLResourceKey.fileAllocatedSizeKey.rawValue)
            ?? 0
    }

    public func getResourceValueForKey(_ key: String) -> Any? {
        let resourceKey = URLResourceKey(key)
        let keySet = Set<URLResourceKey>([resourceKey])

        var val: Any?
        do {
            let values = try resourceValues(forKeys: keySet)
            val = values.allValues[resourceKey]
        } catch _ {
            return nil
        }
        return val
    }

    public func getResourceLongLongForKey(_ key: String) -> Int64? {
        return (getResourceValueForKey(key) as? NSNumber)?.int64Value
    }

    public func getResourceBoolForKey(_ key: String) -> Bool? {
        return getResourceValueForKey(key) as? Bool
    }

    public var isRegularFile: Bool {
        return getResourceBoolForKey(URLResourceKey.isRegularFileKey.rawValue) ?? false
    }

    public func lastComponentIsPrefixedBy(_ prefix: String) -> Bool {
        return (pathComponents.last?.hasPrefix(prefix) ?? false)
    }
}

// The list of permanent URI schemes has been taken from http://www.iana.org/assignments/uri-schemes/uri-schemes.xhtml
private let permanentURISchemes = ["aaa", "aaas", "about", "acap", "acct", "cap", "cid", "coap", "coaps", "crid", "data", "dav", "dict", "dns", "example", "file", "ftp", "geo", "go", "gopher", "h323", "http", "https", "iax", "icap", "im", "imap", "info", "ipp", "ipps", "iris", "iris.beep", "iris.lwz", "iris.xpc", "iris.xpcs", "jabber", "javascript", "ldap", "mailto", "mid", "msrp", "msrps", "mtqp", "mupdate", "news", "nfs", "ni", "nih", "nntp", "opaquelocktoken", "pkcs11", "pop", "pres", "reload", "rtsp", "rtsps", "rtspu", "service", "session", "shttp", "sieve", "sip", "sips", "sms", "snmp", "soap.beep", "soap.beeps", "stun", "stuns", "tag", "tel", "telnet", "tftp", "thismessage", "tip", "tn3270", "turn", "turns", "tv", "urn", "vemmi", "vnc", "ws", "wss", "xcon", "xcon-userid", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "z39.50r", "z39.50s"]

extension URL {
    public init?(nullableString: String?) {
        guard let nonNullString = nullableString else { return nil }
        self.init(string: nonNullString)
    }

    public func withQueryParams(_ params: [URLQueryItem]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        var items = (components.queryItems ?? [])
        for param in params {
            items.append(param)
        }
        components.queryItems = items
        return components.url!
    }

    public func withQueryParam(_ name: String, value: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        let item = URLQueryItem(name: name, value: value)
        components.queryItems = (components.queryItems ?? []) + [item]
        return components.url!
    }

    public func getQuery() -> [String: String] {
        var results = [String: String]()
        let keyValues = self.query?.components(separatedBy: "&")

        if keyValues?.count ?? 0 > 0 {
            for pair in keyValues! {
                let kv = pair.components(separatedBy: "=")
                if kv.count > 1 {
                    results[kv[0]] = kv[1]
                }
            }
        }

        return results
    }

    public var hostPort: String? {
        if let host = self.host {
            if let port = (self as NSURL).port?.int32Value {
                return "\(host):\(port)"
            }
            return host
        }
        return nil
    }

    public var origin: String? {
        guard isWebPage(includeDataURIs: false), let hostPort = self.hostPort, let scheme = scheme else {
            return nil
        }
        return "\(scheme)://\(hostPort)"
    }

    /**
     * Returns a shorter displayable string for a domain
     *
     * E.g., https://m.foo.com/bar/baz?noo=abc#123  => foo
     *       https://accounts.foo.com/bar/baz?noo=abc#123  => accounts.foo
     **/
    public var shortDisplayString: String {
        guard let publicSuffix = self.publicSuffix, let baseDomain = self.normalizedHost else {
            return self.normalizedHost ?? self.absoluteString
        }
        return baseDomain.replacingOccurrences(of: ".\(publicSuffix)", with: "")
    }

    public var normalizedHostAndPath: String? {
        return normalizedHost.flatMap { $0 + self.path }
    }

    public var absoluteDisplayString: String {
        var urlString = self.absoluteString
        // For http URLs, get rid of the trailing slash if the path is empty or '/'
        if (self.scheme == "http" || self.scheme == "https") && (self.path == "/") && urlString.hasSuffix("/") {
            urlString = String(urlString[..<urlString.index(urlString.endIndex, offsetBy: -1)])
        }
        // If it's basic http, strip out the string but leave anything else in
        if urlString.hasPrefix("http://") {
            return String(urlString[urlString.index(urlString.startIndex, offsetBy: 7)...])
        } else {
            return urlString
        }
    }

    /// String suitable for displaying outside of the app, for example in notifications, were Data Detectors will
    /// linkify the text and make it into a openable-in-Safari link.
    public var absoluteDisplayExternalString: String {
        return self.absoluteDisplayString.replacingOccurrences(of: ".", with: "\u{2024}")
    }

    public var displayURL: URL? {
        if AppConstants.IsRunningTest, path.contains("test-fixture/") {
            return self
        }

        if self.absoluteString.starts(with: "blob:") {
            return URL(string: "blob:")
        }

        if self.isFileURL {
            return URL(string: "file://\(self.lastPathComponent)")
        }

        if self.isReaderModeURL {
            return self.decodeReaderModeURL?.havingRemovedAuthorisationComponents()
        }

        if let internalUrl = InternalURL(self), internalUrl.isErrorPage {
            return internalUrl.originalURLFromErrorPage?.displayURL
        }

        if !InternalURL.isValid(url: self) {
            return self.havingRemovedAuthorisationComponents()
        }

        return nil
    }

    /**
    Returns the base domain from a given hostname. The base domain name is defined as the public domain suffix
    with the base private domain attached to the front. For example, for the URL www.bbc.co.uk, the base domain
    would be bbc.co.uk. The base domain includes the public suffix (co.uk) + one level down (bbc).

    :returns: The base domain string for the given host name.
    */
    public var baseDomain: String? {
        guard !isIPv6, let host = host else { return nil }

        // If this is just a hostname and not a FQDN, use the entire hostname.
        if !host.contains(".") {
            return host
        }

        return self.publicSuffixPlusOne
    }

    /**
     * Returns just the domain, but with the same scheme, and a trailing '/'.

     * E.g., https://m.foo.com/bar/baz?noo=abc#123  => https://foo.com/
     *
     * Any failure? Return this URL.
     */
    public var domainURL: URL {
        if let normalized = self.normalizedHost {
            // Use NSURLComponents instead of NSURL since the former correctly preserves
            // brackets for IPv6 hosts, whereas the latter escapes them.
            var components = URLComponents()
            components.scheme = self.scheme
            components.port = self.port
            components.host = normalized
            components.path = "/"
            return components.url ?? self
        }
        return self
    }

    public var normalizedHost: String? {
        // Use components.host instead of self.host since the former correctly preserves
        // brackets for IPv6 hosts, whereas the latter strips them.
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), var host = components.host, !(host.isEmpty) else {
            return nil
        }

        if let range = host.range(of: "^(www|mobile|m)\\.", options: .regularExpression) {
            host.replaceSubrange(range, with: "")
        }

        return host
    }

    /**
    Returns the public portion of the host name determined by the public suffix list found here: https://publicsuffix.org/list/.
    For example for the url www.bbc.co.uk, based on the entries in the TLD list, the public suffix would return co.uk.

    :returns: The public suffix for within the given hostname.
    */
    public var publicSuffix: String? {
        guard let host = host else { return nil }
        guard let result: TLDResult = extractor.parse(host) else { return nil }

        return result.topLevelDomain
    }

    public var publicSuffixPlusOne: String? {
        guard let host = host else { return nil }
        guard let result: TLDResult = extractor.parse(host) else { return nil }

        return (result.secondLevelDomain ?? "") + "." + (result.topLevelDomain ?? "")
    }

    public func isWebPage(includeDataURIs: Bool = true) -> Bool {
        let schemes = includeDataURIs ? ["http", "https", "data"] : ["http", "https"]
        return scheme.map { schemes.contains($0) } ?? false
    }

    public var isHostIPAddress: Bool {
        guard let host = self.host else {
            return false
        }
        guard host != "localhost" else {
            return true
        }
        let components = host.components(separatedBy: ".")
        guard components.count == 4 else {
            return false
        }
        let validNumbersCount = components.compactMap({ Int($0) }).filter({ $0 >= 0 && $0 < 256 })
        return validNumbersCount.count == 4
    }

    public var isIPv6: Bool {
        return host?.contains(":") ?? false
    }

    /**
     Returns whether the URL's scheme is one of those listed on the official list of URI schemes.
     This only accepts permanent schemes: historical and provisional schemes are not accepted.
     */
    public var schemeIsValid: Bool {
        guard let scheme = scheme else { return false }
        return permanentURISchemes.contains(scheme.lowercased())
    }

    public func havingRemovedAuthorisationComponents() -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        urlComponents.user = nil
        urlComponents.password = nil
        if let url = urlComponents.url {
            return url
        }
        return self
    }

    public func isEqual(_ url: URL) -> Bool {
        if self == url {
            return true
        }

        // Try an additional equality case by chopping off the trailing slash
        let urls: [String] = [url.absoluteString, absoluteString].map { item in
            if let lastCh = item.last, lastCh == "/" {
                return item.dropLast().lowercased()
            }
            return item.lowercased()
        }
        return urls[0] == urls[1]
    }
}

// Extensions to deal with ReaderMode URLs

extension URL {
    public var isReaderModeURL: Bool {
        let scheme = self.scheme, host = self.host, path = self.path
        return scheme == "http" && host == "localhost" && path == "/reader-mode/page"
    }

    public var isSyncedReaderModeURL: Bool {
        return self.absoluteString.hasPrefix("about:reader?url=")
    }

    public var decodeReaderModeURL: URL? {
        if self.isReaderModeURL || self.isSyncedReaderModeURL {
            if let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems {
                if let queryItem = queryItems.find({ $0.name == "url"}), let value = queryItem.value {
                    return URL(string: value)
                }
            }
        }
        return nil
    }

    public func encodeReaderModeURL(_ baseReaderModeURL: String) -> URL? {
        if let encodedURL = absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
            if let aboutReaderURL = URL(string: "\(baseReaderModeURL)?url=\(encodedURL)") {
                return aboutReaderURL
            }
        }
        return nil
    }
}

// Helpers to deal with ErrorPage URLs

public struct InternalURL {
    public static let uuid = UUID().uuidString
    public static let scheme = "internal"
    public static let baseUrl = "\(scheme)://local"

    public static func createQueryItem(url: URL) -> URLQueryItem {
        return URLQueryItem(name: InternalURL.Param.url.rawValue, value: url.absoluteString.toBase64().escape())
    }

    public enum Path: String {
        case errorpage = "errorpage"
        case sessionrestore = "sessionrestore"
        func matches(_ string: String) -> Bool {
            return string.range(of: "/?\(self.rawValue)", options: .regularExpression, range: nil, locale: nil) != nil
        }
    }

    public enum Param: String {
        case uuidkey = "uuidkey"
        case url = "url"
        func matches(_ string: String) -> Bool { return string == self.rawValue }
    }

    public let url: URL

    private let sessionRestoreHistoryItemBaseUrl = "\(InternalURL.baseUrl)/\(InternalURL.Path.sessionrestore.rawValue)?url="

    public static func isValid(url maybeUrl: URL?) -> Bool {
        guard let url = maybeUrl else { return false }
        let isWebServerUrl = url.absoluteString.hasPrefix("http://localhost:\(AppInfo.webserverPort)/")
        if isWebServerUrl, url.path.hasPrefix("/test-fixture/") {
            // internal test pages need to be treated as external pages
            return false
        }

        // (reader-mode-custom-scheme) remove isWebServerUrl when updating code.
        return isWebServerUrl || InternalURL.scheme == url.scheme
    }

    public init?(_ url: URL) {
        guard InternalURL.isValid(url: url) else {
            return nil
        }

        self.url = url
    }

    public var isAuthorized: Bool {
        return (url.getQuery()[InternalURL.Param.uuidkey.rawValue] ?? "") == InternalURL.uuid
    }

    public var stripAuthorization: String {
        guard var components = URLComponents(string: url.absoluteString), let items = components.queryItems else { return url.absoluteString }
        components.queryItems = items.filter { !Param.uuidkey.matches($0.name) }
        if let items = components.queryItems, items.isEmpty {
            components.queryItems = nil // This cleans up the url to not end with a '?'
        }
        return components.url?.absoluteString ?? ""
    }

    public static func authorize(url: URL) -> URL? {
        guard var components = URLComponents(string: url.absoluteString) else { return nil }
        if components.queryItems == nil {
            components.queryItems = []
        }

        if var item = components.queryItems?.find({ Param.uuidkey.matches($0.name) }) {
            item.value = InternalURL.uuid
        } else {
            components.queryItems?.append(URLQueryItem(name: Param.uuidkey.rawValue, value: InternalURL.uuid))
        }
        return components.url
    }

    public var isSessionRestore: Bool {
        return url.absoluteString.hasPrefix(sessionRestoreHistoryItemBaseUrl)
    }

    public var isErrorPage: Bool {
        // Error pages can be nested in session restore URLs, and session restore handler will forward them to the error page handler
        let path = url.absoluteString.hasPrefix(sessionRestoreHistoryItemBaseUrl) ? extractedErrorPageUrlParam?.path : url.path
        return InternalURL.Path.errorpage.matches(path ?? "")
    }

    public var originalURLFromErrorPage: URL? {
        if !url.absoluteString.hasPrefix(sessionRestoreHistoryItemBaseUrl) {
            return isErrorPage ? extractedErrorPageUrlParam : nil
        }
        if let urlParam = extractedErrorPageUrlParam, let nested = InternalURL(urlParam), nested.isErrorPage {
            return nested.extractedErrorPageUrlParam
        }
        return nil
    }

    public var extractedErrorPageUrlParam: URL? {
        if let nestedUrl = url.getQuery()[InternalURL.Param.url.rawValue]?.unescape()?.fromBase64() {
            return URL(string: nestedUrl)
        }
        return nil
    }

    public var extractedUrlParam: URL? {
        if let nestedUrl = url.getQuery()[InternalURL.Param.url.rawValue]?.unescape() {
            return URL(string: nestedUrl)
        }
        return nil
    }

    public var isAboutHomeURL: Bool {
        if let urlParam = extractedUrlParam, let internalUrlParam = InternalURL(urlParam) {
            return internalUrlParam.aboutComponent?.hasPrefix("home") ?? false
        }
        return aboutComponent?.hasPrefix("home") ?? false
    }

    public var isAboutURL: Bool {
        return aboutComponent != nil
    }

    /// Return the path after "about/" in the URI.
    public var aboutComponent: String? {
        let aboutPath = "/about/"
        guard let url = URL(string: stripAuthorization) else {
            return nil
        }

        if url.path.hasPrefix(aboutPath) {
            return String(url.path.dropFirst(aboutPath.count))
        }
        return nil
    }
}
