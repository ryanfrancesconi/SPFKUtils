import Foundation

public class SecureURLRegistry {
    public private(set) static var active = Set<URL>()
    public private(set) static var stale = Set<URL>()
    public private(set) static var errors = Set<URL>()

    @discardableResult
    public static func create(from bookmarkData: Data) throws -> URL {
        var isStale = false

        let url = try URL(
            resolvingBookmarkData: bookmarkData,
            options: [.withSecurityScope],
            bookmarkDataIsStale: &isStale
        )

        guard !isStale else {
            stale.insert(url)
            throw NSError(
                description: "File at \(url.path) isn't accessible.",
                domain: NSURLErrorDomain,
                code: NSURLErrorCannotOpenFile
            )
        }

        guard url.startAccessingSecurityScopedResource() else {
            errors.insert(url)

            let message = "startAccessingSecurityScopedResource failed for \(url.path)"

            assertionFailure(message)

            throw NSError(
                description: message,
                domain: NSURLErrorDomain,
                code: NSURLErrorCannotOpenFile
            )
        }

        active.insert(url)

        return url
    }

    public static func releaseAll() {
        Log.debug("Releasing", active.count, "active urls,", stale.count, "stale")

        active.forEach {
            $0.stopAccessingSecurityScopedResource()
        }

        stale.forEach {
            $0.stopAccessingSecurityScopedResource()
        }

        active.removeAll()
        stale.removeAll()
        errors.removeAll()
    }
}
