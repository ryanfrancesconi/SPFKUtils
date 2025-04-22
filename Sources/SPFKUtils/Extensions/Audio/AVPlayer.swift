// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi/SPFKUtils

import AVFoundation

extension AVPlayer {
    public var isPlaying: Bool {
        (rate != 0) && (error == nil)
    }
}
