import AppKit
import AudioToolbox
import SPFKUtils
import Testing

final class NumberTests: BinTestCase {
    @Test func normalized() {
        let value: AUValue = 1

        #expect(
            value.normalized(from: 0 ... 2, taper: AUValue(3)) == 0.7937005
        )
    }

    @Test func fourCharCode() throws {
        let v1: FourCharCode = 1635083896
        let s1 = try #require(v1.fourCharCodeToString())

        #expect(s1 == "aufx")
        #expect(s1 == v1.fromHFSTypeCode())
        #expect(v1 == s1.fourCharCode)

        let v2: FourCharCode = 1298229066
        let s2 = v2.fourCharCodeToString()
        #expect(s2 == "MagJ")
        #expect(s2 == v2.fromHFSTypeCode())

        // test invalid value
        let v3: FourCharCode = 130071762
        let s3 = v3.fourCharCodeToString()
        #expect(s3 == nil)
    }
}
