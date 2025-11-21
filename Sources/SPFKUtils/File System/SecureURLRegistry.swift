import Foundation

/// A centralized place to store URL access to simplify matching start access with stop
public actor SecureURLRegistry {
    public static let shared = SecureURLRegistry()
    private init (){}
    
    public private(set) var active = Set<URL>()
    public private(set) var stale = Set<URL>()
    public private(set) var errors = Set<URL>()

    @discardableResult
    public func create(resolvingBookmarkData data: Data) throws -> URL {
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: data,
            options: [.withSecurityScope],
            bookmarkDataIsStale: &isStale
        )

        guard !isStale else {
            stale.insert(url)

            throw NSError(
                domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, description: "File at \(url.path) isn't accessible."
            )
        }

        guard url.startAccessingSecurityScopedResource() else {
            errors.insert(url)

            let message = "startAccessingSecurityScopedResource failed for \(url.path)"

            assertionFailure(message)

            throw NSError(
                domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, description: message
            )
        }

        active.insert(url)

        return url
    }

    public func releaseAll() {
        Log.debug("Releasing", active.count, "security scoped urls,", stale.count, "stale")

        active.forEach {
            $0.stopAccessingSecurityScopedResource()
        }

        active.removeAll()
        stale.removeAll()
        errors.removeAll()
    }
}
