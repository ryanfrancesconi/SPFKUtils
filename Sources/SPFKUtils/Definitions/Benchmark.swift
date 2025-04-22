// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import Foundation
import QuartzCore

/// Simple timing utility
public class Benchmark {
    public private(set) var startScanTime: CFTimeInterval = 0
    public private(set) var endScanTime: CFTimeInterval = 0
    public private(set) var label: String = ""
    public private(set) var isStarted = false

    public init(label: String? = nil) {
        if let label {
            start(label: label)
        }
    }

    public func start(funcName: String = #function,
                      file: String = #file,
                      label: String = "") {
        if isStarted { stop() }

        self.label = label
        isStarted = true
        startScanTime = CACurrentMediaTime()
        Log.debug(file: file,
                  function: funcName,
                  "⏱🟢 \(label)")
    }

    public func elapsed(funcName: String = #function,
                        file: String = #file,
                        label: String = "") {
        let elapsed = CACurrentMediaTime() - startScanTime

        Log.debug(file: file,
                  function: funcName,
                  "⏱🔴 \(label) \(elapsed) elapsed seconds.")
    }

    @discardableResult
    public func stop(funcName: String = #function,
                     file: String = #file) -> CFTimeInterval {
        guard isStarted else { return -1 }
        endScanTime = CACurrentMediaTime() - startScanTime

        Log.debug(file: file,
                  function: funcName,
                  "⏱🔴 \(label) took \(endScanTime) seconds.")

        isStarted = false
        return endScanTime
    }
}
