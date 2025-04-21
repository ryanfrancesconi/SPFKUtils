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
        var v1: FourCharCode = 1635083896
        var s1 = v1.fourCharCodeToString()
        #expect(s1 == "aufx")
        #expect(s1 == v1.fromHFSTypeCode())

        v1 = 1298229066
        s1 = v1.fourCharCodeToString()
        #expect(s1 == "MagJ")
        #expect(s1 == v1.fromHFSTypeCode())

        // test invalid value
        let v2: FourCharCode = 130071762
        let s2 = v2.fourCharCodeToString()
        #expect(s2 == nil)
    }
}
