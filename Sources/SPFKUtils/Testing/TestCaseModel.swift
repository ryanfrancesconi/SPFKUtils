// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation

public protocol TestCaseModel: TypeDescribable {
    var bin: URL { get }
    var deleteBinOnExit: Bool { get set }
}

extension TestCaseModel {
    public var bin: URL { defaultURL }

    public var deleteBinOnExit: Bool {
        get { false }
        set {}
    }
}

extension TestCaseModel {
    public var defaultURL: URL {
        FileManager.default.temporaryDirectory
    }

    public func createBin(suite: String? = nil, in baseURL: URL? = nil) -> URL {
        let suite = suite ?? typeName
        var url = baseURL ?? defaultURL

        url = url.appendingPathComponent(suite)

        if !url.exists {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
                Log.debug("Created bin at \(url.path)")

            } catch {
                Log.error(error)

                if url != FileManager.default.temporaryDirectory {
                    return createBin(suite: suite, in: FileManager.default.temporaryDirectory)
                }
            }
        }

        return url
    }

    public func copyToBin(url: URL) throws -> URL {
        try copy(to: bin, url: url)
    }

    public func copyToBin(urls: [URL]) throws -> [URL] {
        urls.compactMap {
            try? copyToBin(url: $0)
        }
    }

    private func copy(to bin: URL, url input: URL) throws -> URL {
        let tmp = bin.appendingPathComponent(input.lastPathComponent)
        try? FileManager.default.removeItem(at: tmp)
        try FileManager.default.copyItem(at: input, to: tmp)
        return tmp
    }

    public func createTempFile(for suite: String, source: URL) throws -> URL? {
        let bin = createBin(suite: suite)
        let tmpfile = try copy(to: bin, url: source)

        guard tmpfile.exists else { return nil }

        return tmpfile
    }

    public func removeBin() {
        guard bin.exists else { return }

        do {
            Log.debug("Removing \(bin.path)")
            try bin.delete()

        } catch {
            Log.error(error)
        }
    }
}

extension TestCaseModel {
    public func wait(sec timeout: TimeInterval) async throws {
        try await Task.sleep(seconds: timeout)
    }

    public func wait(
        for condition: @escaping @autoclosure () -> Bool,
        timeout: TimeInterval,
        polling: TimeInterval = 0.1
    ) async throws {
        let inTime = Date()
        let timeoutTime = inTime + timeout

        var timedOut = false

        while true {
            if Date() >= timeoutTime {
                timedOut = true
                break
            }

            try await wait(sec: polling)

            let result = condition()

            if result {
                break
            }
        }

        if timedOut {
            throw NSError(description: "Timeout failed to meet condition")
        }
    }
}
