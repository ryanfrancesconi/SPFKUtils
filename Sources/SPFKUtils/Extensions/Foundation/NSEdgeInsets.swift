// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/spfk-utils

#if os(macOS)
    import Foundation

    extension NSEdgeInsets {
        public init(equal value: CGFloat) {
            self.init(top: value, left: value, bottom: value, right: value)
        }
    }
#endif
