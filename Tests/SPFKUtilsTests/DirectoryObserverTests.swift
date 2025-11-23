#if os(macOS)
    import Checksum
    import Foundation
    import SPFKTesting
    import SPFKUtils
    import Testing

    @Suite(.serialized)
    final class DirectoryObserverTests: BinTestCase, @unchecked Sendable {
        var added = [URL]()
        var removed = [URL]()

        @Test func testDirectoryObserver() async throws {
            #expect(bin.exists)

            let observer = try DirectoryEnumerationObserver(url: bin, delegate: self)
            try await observer.start()

            let urls = TestBundleResources.shared.formats
            let newFiles = try copyToBin(urls: urls)
            Log.debug("Copied to", newFiles)

            try await wait(sec: 3) // must give it time to register

            #expect(added.count == urls.count)

            try newFiles.first?.delete()
            try await wait(sec: 3) // must give it time to register
            #expect(removed.count == 1)

            newFiles.forEach {
                try? $0.delete()
            }

            try await wait(sec: 3) // must give it time to register
            #expect(removed.count == urls.count)

            await observer.stop()

            added.removeAll()
            removed.removeAll()
        }
    }

    extension DirectoryObserverTests: DirectoryEnumerationObserverDelegate {
        public func directoryUpdated(events: Set<DirectoryEvent>) async throws {
            for event in events {
                switch event {
                case let .new(files: files, source: from):
                    Log.debug("+ New", files, "in", from)
                    added += files

                case let .removed(files: files, source: from):
                    Log.debug("- Removed", files, "in", from)
                    removed += files
                }
            }
        }
    }
#endif
