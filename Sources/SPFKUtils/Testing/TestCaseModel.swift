import Foundation

public protocol TestCaseModel {}

extension TestCaseModel {
    public func createBin(suite: String, in baseURL: URL? = nil) -> URL {
        var url = baseURL ?? FileManager.default.temporaryDirectory

        url = url.appendingPathComponent(suite)

        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            } catch {
                Swift.print(error)

                if url != FileManager.default.temporaryDirectory {
                    return createBin(suite: suite, in: FileManager.default.temporaryDirectory)
                }
            }
        }

        return url
    }

    public func copy(to bin: URL, url input: URL) throws -> URL {
        let tmp = bin.appendingPathComponent(input.lastPathComponent)
        try? FileManager.default.removeItem(at: tmp)
        try FileManager.default.copyItem(at: input, to: tmp)
        return tmp
    }

    public func createTempFile(for suite: String, source: URL) throws -> URL? {
        let bin = createBin(suite: suite)
        let tmpfile = try copy(to: bin, url: source)

        guard FileManager.default.fileExists(atPath: tmpfile.path) else { return nil }

        return tmpfile
    }
}

extension TestCaseModel {
    public func wait(sec timeout: TimeInterval) async {
        try? await Task.sleep(seconds: timeout)
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

            await wait(sec: polling)

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
