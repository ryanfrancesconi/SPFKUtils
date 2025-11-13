import AVFoundation
import Foundation
import SPFKTesting
import SPFKUtils
import Testing

class ExceptionTrapTests: TestCaseModel {
    @Test func swiftError() throws {
        func throwError() throws {
            throw NSError(description: #function)
        }

        #expect(throws: Error.self) {
            try ExceptionTrap.withThrowing { try throwError() }
        }
    }

    @Test func nsError() async throws {
        #expect(throws: Error.self) {
            // 'required condition is false: _engine != nil'
            try ExceptionTrap.withThrowing { AVAudioPlayerNode().play() }
        }
    }
}
