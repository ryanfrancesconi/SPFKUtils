import Checksum
import Foundation
import SPFKTesting
import SPFKUtils
import Testing

@Suite(.serialized)
public class DirectoryObserverTests: BinTestCase {
    var filesAdded = [URL]()
    var filesRemoved = [URL]()

    @Test func testDirectoryObserver() async throws {
        #expect(bin.exists)

        let observer = try DirectoryEnumerationObserver(url: bin)
        observer.delegate = self
        try await observer.start()

        let file = TestBundleResources.shared.mp3_id3

        let newFile = bin.appendingPathComponent(file.lastPathComponent)

        if newFile.exists { try newFile.delete() }

        try FileManager.default.copyItem(at: file, to: newFile)

        Log.debug("Copied to", newFile.path)

        try await wait(sec: 5) // must give it time to register

        #expect(filesAdded.count == 1)

        try newFile.delete()

        try await wait(sec: 5) // must give it time to register

        #expect(filesRemoved.count == 1)

        observer.stop()

        try await wait(sec: 1)

        filesAdded.removeAll()
        filesRemoved.removeAll()
    }
}

extension DirectoryObserverTests: DirectoryEnumerationObserverDelegate {
    public func directoryUpdated(events: [DirectoryEvent]) async throws {
        for event in events {
            switch event {
            case let .new(files: files, source: from):
                Log.debug("🟢 New", files, "in", from)
                filesAdded += files

            case let .removed(files: files, source: from):
                Log.debug("🔴 Removed", files, "in", from)
                filesRemoved += files
            }
        }
    }
}
